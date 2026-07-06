// supabase/functions/interpret/index.ts
// POST /functions/v1/interpret
// 基于排盘结果生成 LLM 解读 (Tier 1 brief / Tier 2 detailed).
// Provider: FreeLLMAPI (试用) → DeepSeek (生产), 由 FREELLMAPI_URL/KEY 或
//                          DEEPSEEK_API_KEY 切换，详见 README.md.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface InterpretRequest {
  system:
    | 'bazi' | 'tarot' | 'qimen' | 'ziwei'
    | 'iching' | 'meihua' | 'astro' | 'dream';
  tier: 'brief' | 'detailed';
  locale: 'en' | 'zh-CN';
  chart: Record<string, unknown>;
}

interface UpstreamChatResponse {
  choices?: Array<{ message?: { content?: string } }>;
  error?: { message?: string };
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
declare const Deno: any;

const SYSTEM_NAME_ZH: Record<string, string> = {
  bazi: '八字',
  tarot: '塔罗',
  qimen: '奇门遁甲',
  ziwei: '紫微斗数',
  iching: '易经 / 六爻',
  meihua: '梅花易数',
  astro: '西方占星',
  dream: '周公解梦',
};

const SYSTEM_NAME_EN: Record<string, string> = {
  bazi: 'Bazi (Four Pillars)',
  tarot: 'Tarot',
  qimen: 'Qimen Dunjia',
  ziwei: 'Zi Wei Dou Shu',
  iching: 'I Ching',
  meihua: 'Plum Blossom Numerology',
  astro: 'Western Astrology',
  dream: 'Zhou Gong Dream Interpretation',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: InterpretRequest = await req.json().catch(() => ({} as InterpretRequest));

    if (!body || !body.system || !body.chart || !body.tier || !body.locale) {
      return jsonResponse(req, {
        error: 'Missing required fields. Expected {system, chart, tier, locale}.',
      }, 400);
    }

    if (!Object.prototype.hasOwnProperty.call(SYSTEM_NAME_EN, body.system)) {
      return jsonResponse(req, { error: `Unsupported system: ${body.system}` }, 400);
    }

    if (body.tier !== 'brief' && body.tier !== 'detailed') {
      return jsonResponse(req, { error: 'tier must be "brief" or "detailed"' }, 400);
    }

    // 归一化 locale: Flutter 的 languageCode 只给 "zh"/"en", 也可能来
    // "zh-Hans"/"zh-TW" 等完整 tag —— zh* 一律按简中处理, 其余回落英文.
    const locale: 'en' | 'zh-CN' =
      String(body.locale ?? '').toLowerCase().startsWith('zh') ? 'zh-CN' : 'en';
    body.locale = locale;

    // === Provider configuration ===
    // 通用三件套 (推荐, 适配任何 OpenAI 兼容 API: MiniMax / DeepSeek / FreeLLMAPI):
    //   LLM_BASE_URL   如 https://api.minimaxi.com/v1
    //   LLM_API_KEY
    //   LLM_MODEL      如 MiniMax-Text-01 (可选 LLM_MODEL_BRIEF / LLM_MODEL_DETAILED 分层覆盖)
    // 旧变量 FREELLMAPI_URL/KEY、DEEPSEEK_API_KEY 仍兼容.
    const isPublicRelease = Deno.env.get('IS_PUBLIC_RELEASE') === 'true';

    const url = Deno.env.get('LLM_BASE_URL') ??
      Deno.env.get('FREELLMAPI_URL') ??
      'http://localhost:3001/v1';
    const key = Deno.env.get('LLM_API_KEY') ??
      Deno.env.get('FREELLMAPI_KEY') ??
      Deno.env.get('DEEPSEEK_API_KEY') ??
      '';

    if (isPublicRelease && url.includes('localhost')) {
      return jsonResponse(req, {
        error:
          'Production release blocked: LLM endpoint still points to localhost. Configure DEEPSEEK_API_KEY.',
      }, 503);
    }

    if (!key) {
      return jsonResponse(req, {
        error:
          'No LLM API key configured. Set FREELLMAPI_KEY (dev) or DEEPSEEK_API_KEY (prod).',
      }, 500);
    }

    const { prompt, model, maxTokens } = buildPrompt(
      body.system,
      body.chart,
      body.tier,
      body.locale,
    );

    // 超时兜底: 上游 LLM 挂起时不能让用户无限等 (brief 60s / detailed 120s)
    const timeoutMs = body.tier === 'detailed' ? 120_000 : 60_000;
    const llmRes = await fetch(`${url.replace(/\/$/, '')}/chat/completions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.8,
        max_tokens: maxTokens,
        stream: false,
      }),
      signal: AbortSignal.timeout(timeoutMs),
    });

    if (!llmRes.ok) {
      const errText = await llmRes.text();
      return jsonResponse(req, {
        error: `Upstream ${llmRes.status}: ${errText.slice(0, 500)}`,
      }, 502);
    }

    const data: UpstreamChatResponse = await llmRes.json();
    const rawContent: string = data?.choices?.[0]?.message?.content ?? '';
    // 推理模型 (MiniMax M 系列 / DeepSeek R 系列等) 会把思考过程放在
    // <think>...</think> 里混在 content 返回, 必须剥掉再给用户.
    // 兜底: 有 <think> 开头但没闭合标签时 (截断), 整段丢弃避免泄漏思考过程.
    let interpretation = rawContent.replace(/<think>[\s\S]*?<\/think>/g, '').trim();
    if (interpretation.startsWith('<think>')) interpretation = '';

    if (!interpretation) {
      return jsonResponse(req, { error: 'LLM returned empty interpretation' }, 502);
    }

    return jsonResponse(req, {
      interpretation,
      model,
      locale: body.locale,
      tier: body.tier,
      system: body.system,
      charsLength: interpretation.length,
    });
  } catch (e) {
    return jsonResponse(req, {
      error: e instanceof Error ? e.message : 'Unknown error',
    }, 500);
  }
});

/** 从盘面里尽力挖出出生年份 (bazi.birthInfo.solarDate / ziwei.solarDate / astro.natal.origin.localDateTime) */
function findBirthYear(chart: Record<string, unknown>): number | null {
  const candidates: unknown[] = [
    (chart.birthInfo as Record<string, unknown> | undefined)?.solarDate,
    chart.solarDate,
    ((chart.natal as Record<string, unknown> | undefined)?.origin as Record<string, unknown> | undefined)?.localDateTime,
  ];
  for (const c of candidates) {
    const m = String(c ?? '').match(/(19|20)\d{2}/);
    if (m) return Number(m[0]);
  }
  return null;
}

function buildPrompt(
  system: string,
  chart: Record<string, unknown>,
  tier: 'brief' | 'detailed',
  locale: 'en' | 'zh-CN',
): { prompt: string; model: string; maxTokens: number } {
  const langWord = locale === 'zh-CN' ? '简体中文' : 'English';
  const systemName = locale === 'zh-CN'
    ? SYSTEM_NAME_ZH[system]
    : SYSTEM_NAME_EN[system];
  const chartJson = JSON.stringify(chart, null, 2).slice(0, 12000);

  // ===== 时间上下文 (关键!) =====
  // LLM 不知道"今天"是哪天。不注入当前日期, 它面对大限/大运列表只能瞎选,
  // 曾出现把 1990 年生人在 2026 年说成"正行 46-55 岁大限"的严重错误。
  const nowCn = new Intl.DateTimeFormat('zh-CN', {
    timeZone: 'Asia/Shanghai', year: 'numeric', month: '2-digit', day: '2-digit',
  }).format(new Date());
  const birthYear = findBirthYear(chart);
  const currentYearNum = Number(nowCn.slice(0, 4));
  const ageLine = birthYear
    ? (locale === 'zh-CN'
        ? `命主生于 ${birthYear} 年，今年（${currentYearNum} 年）周岁约 ${currentYearNum - birthYear} 岁、虚岁约 ${currentYearNum - birthYear + 1} 岁。`
        : `The person was born in ${birthYear}; as of ${currentYearNum} they are about ${currentYearNum - birthYear} years old.`)
    : '';
  const timeContext = locale === 'zh-CN'
    ? `【时间基准】今天的公历日期是 ${nowCn}。${ageLine}\n涉及"当前大限/大运/流年/年龄"的一切论断，必须以上述日期和年龄为准来选择区间——例如大运列表里哪一步的起讫年份包含 ${currentYearNum} 年，那才是"当前"。选错年龄区间是最严重的错误。`
    : `[Time anchor] Today's date is ${nowCn}. ${ageLine}\nAny claim about the "current" decadal luck period / annual luck / age MUST be selected using this date — e.g. the luck period whose year range contains ${currentYearNum} is the current one. Getting the age bracket wrong is the most serious possible error.`;

  const systemInstruction = locale === 'zh-CN'
    ? `你是 Fortune Master 「中西算命大全」APP 的资深命理师顾问。你的解读必须 (1) 基于提供的 ${systemName} 排盘数据，不编造数据; (2) 语气温和、神秘但不神棍; (3) 明确不构成医疗、法律、财务、心理、职业等专业建议; (4) 不替用户做命运裁决; (5) 末尾加一句：以上解读仅供娱乐参考，不构成专业建议。\n\n${timeContext}`
    : `You are a senior divination consultant for Fortune Master, a bilingual Chinese-Western fortune-telling app. Your interpretation must: (1) ground every claim in the ${systemName} chart data provided — never invent; (2) be warm and mystical without being preachy; (3) include an explicit disclaimer that it is NOT a substitute for medical, legal, financial, psychological, or career advice; (4) refrain from making deterministic life predictions; (5) end with: "This interpretation is for entertainment only and is not professional advice."\n\n${timeContext}`;

  // 周公解梦: 没有"排盘", chart 是 {dream: 梦境描述}。走专用 prompt。
  if (system === 'dream') {
    const dreamText = String((chart as Record<string, unknown>).dream ?? '').slice(0, 2000);
    const dreamPrompt = locale === 'zh-CN'
      ? `${systemInstruction}\n\n用户描述的梦境：\n"""\n${dreamText}\n"""\n\n请按《周公解梦》的传统象征体系解读这个梦，${tier === 'brief' ? '300 字左右' : '600-900 字'}。要求：\n1. 先点名梦中出现的关键意象（如水、蛇、飞行），并给出传统典籍中的象征含义\n2. 结合现代心理学视角给一层温和的补充解释\n3. 给一条可执行的温和建议\n4. 不做吉凶断言，尤其不预测疾病、死亡、灾祸`
      : `${systemInstruction}\n\nThe user's dream:\n"""\n${dreamText}\n"""\n\nInterpret this dream in the tradition of Zhou Gong dream symbolism (${tier === 'brief' ? '~300 words' : '600-900 words'}). Requirements:\n1. Name the key symbols that appeared in the dream and their traditional meanings\n2. Add a gentle modern-psychology perspective\n3. One gentle, actionable suggestion\n4. No fortune/misfortune verdicts — especially no predictions of illness, death, or disaster`;
    return {
      prompt: dreamPrompt,
      model: pickModel(tier, locale),
      maxTokens: tier === 'brief' ? 3500 : 6000,
    };
  }

  if (tier === 'brief') {
    const userPrompt = locale === 'zh-CN'
      ? `${systemInstruction}\n\n以下是用户的${systemName}排盘数据：\n\`\`\`json\n${chartJson}\n\`\`\`\n\n请用${langWord}给出一段 300-400 字的解读。硬性要求：\n1. 开头第一句必须先复述排盘的核心事实（八字要点名四柱干支和日主，塔罗要点名抽到的牌，奇门要点名局数和值符值使），让用户确认这是"他自己的盘"\n2. 每个论断都要挂在具体的盘面符号上（如"因为你时柱透出X"），不许写放之四海皆准的空话\n3. 覆盖：性格核心特征 / 当前运势提示 / 一条可执行的温和建议`
      : `${systemInstruction}\n\nHere is the user's ${systemName} chart data:\n\`\`\`json\n${chartJson}\n\`\`\`\n\nReply in ${langWord} (300-400 words). Hard requirements:\n1. The FIRST sentence must restate the core facts of THIS chart (for Bazi: the four pillars and day master; for Tarot: the exact cards drawn; for Qimen: the ju number and chief star/gate) so the user can confirm it is their own chart\n2. Anchor every claim to a specific symbol in the chart ("because your hour pillar shows X") — no generic statements that could apply to anyone\n3. Cover: core personality / current trend / one gentle, actionable suggestion`;

    // 注: 推理模型 (MiniMax M / DeepSeek R) 的思考过程也消耗 max_tokens,
    // 预算必须给足, 否则正文还没开始就被截断.
    // 实测 (MiniMax-M2.7-highspeed + 完整八字 chart): 2000 截断, 3000 完整; 取 3500 留余量.
    return { prompt: userPrompt, model: pickModel(tier, locale), maxTokens: 3500 };
  }

  // detailed: 全维度深度解读. 命理类 (bazi/ziwei) 强调大运/大限时间轴;
  // 占卜类 (tarot/iching/meihua/qimen) 强调事项吉凶与时机; astro 强调行运.
  const isDestinyChart = system === 'bazi' || system === 'ziwei' || system === 'astro';
  const zhDimensions = isDestinyChart
    ? `1. 命局总览 —— 格局、五行强弱、用神喜忌（点名具体干支/星曜佐证）
2. 性格与天赋 —— 深层性格、适合的发展方向
3. 当前所处阶段 —— 先按【时间基准】算准年龄，指出现在正行哪一步大运/大限（引用它的干支或宫位和起讫年份），当前处境如何
4. 未来 10-15 年运势走向 —— 按大运/大限列表逐步展开：每一步引用具体干支（或宫位）与起讫年份，说明该阶段事业/财运/健康的总体趋势与关键转折点
5. 财运 —— 正财偏财格局、聚财方式、破财风险点
6. 事业与学业 —— 适合行业、贵人方位、发展节奏
7. 感情与婚姻 —— 婚恋特质、相处课题、有利时段
8. 健康 —— 五行偏枯对应的养生重点（不做疾病诊断）
9. 开运建议 —— 基于用神喜忌的颜色/方位/行业等 3-5 条可执行建议`
    : `1. 盘面总览 —— 核心格局与吉凶大势（点名具体符号佐证）
2. 所问之事的直接答案 —— 结合问题给出倾向性判断与理由
3. 时机分析 —— 何时行动有利、何时宜守（引用盘面依据）
4. 财运相关提示
5. 事业/所谋之事的走向
6. 感情与人际维度的提示
7. 风险与注意事项
8. 3-5 条可执行建议`;
  const enDimensions = isDestinyChart
    ? `1. Chart overview — structure, elemental balance, favorable elements (cite specific pillars/stars)
2. Personality & talents
3. Current life stage — FIRST compute the age per the time anchor, then identify which decadal period is active NOW (cite its stems/palace and year range)
4. The next 10-15 years — walk through the decadal luck list step by step, citing each period's stems/palace and year range, with the overall trend and turning points of each
5. Wealth — patterns, how money comes, leak risks
6. Career & studies
7. Love & marriage
8. Health focus areas (no medical diagnosis)
9. 3-5 actionable suggestions based on favorable elements`
    : `1. Chart overview — core pattern and overall tendency (cite specific symbols)
2. Direct answer to the question asked, with reasoning
3. Timing — when to act, when to hold (cite the chart)
4. Wealth-related hints
5. Career / the matter asked about
6. Relationships
7. Risks and cautions
8. 3-5 actionable suggestions`;

  const userPrompt = locale === 'zh-CN'
    ? `${systemInstruction}\n\n以下是用户的${systemName}排盘数据：\n\`\`\`json\n${chartJson}\n\`\`\`\n\n请用${langWord}给出完整结构化深度解读（1500-2500 字），按以下维度逐节展开，每节都必须引用具体盘面数据佐证，禁止写放之四海皆准的空话：\n${zhDimensions}`
    : `${systemInstruction}\n\nHere is the user's ${systemName} chart data:\n\`\`\`json\n${chartJson}\n\`\`\`\n\nReply in ${langWord} with a full structured deep reading (1500-2500 words), section by section as below. Every section must cite specific chart data — no generic filler:\n${enDimensions}`;

  return { prompt: userPrompt, model: pickModel(tier, locale), maxTokens: 12000 };
}

function pickModel(tier: 'brief' | 'detailed', locale: 'en' | 'zh-CN'): string {
  // 优先级: 分层覆盖 > 通用覆盖 > FreeLLMAPI 默认路由表.
  // 换 provider (MiniMax/DeepSeek/...) 只需设 LLM_MODEL, 不用改代码 ——
  // 下面的 FreeLLMAPI 风格模型名 (zhipu/... github/...) 其他 provider 不认识.
  const tierOverride = tier === 'detailed'
    ? Deno.env.get('LLM_MODEL_DETAILED')
    : Deno.env.get('LLM_MODEL_BRIEF');
  const override = tierOverride ?? Deno.env.get('LLM_MODEL');
  if (override) return override;

  if (locale === 'zh-CN') {
    return tier === 'detailed' ? 'cloudflare/kimi-k2' : 'zhipu/glm-4.5';
  }
  return tier === 'detailed' ? 'github/gpt-4.1' : 'github/gpt-4o-mini';
}
