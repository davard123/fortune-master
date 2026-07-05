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
  const chartJson = JSON.stringify(chart, null, 2).slice(0, 6000);

  const systemInstruction = locale === 'zh-CN'
    ? `你是 Fortune Master 「中西算命大全」APP 的资深命理师顾问。你的解读必须 (1) 基于提供的 ${systemName} 排盘数据，不编造数据; (2) 语气温和、神秘但不神棍; (3) 明确不构成医疗、法律、财务、心理、职业等专业建议; (4) 不替用户做命运裁决; (5) 末尾加一句：以上解读仅供娱乐参考，不构成专业建议。`
    : `You are a senior divination consultant for Fortune Master, a bilingual Chinese-Western fortune-telling app. Your interpretation must: (1) ground every claim in the ${systemName} chart data provided — never invent; (2) be warm and mystical without being preachy; (3) include an explicit disclaimer that it is NOT a substitute for medical, legal, financial, psychological, or career advice; (4) refrain from making deterministic life predictions; (5) end with: "This interpretation is for entertainment only and is not professional advice."`;

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

  const userPrompt = locale === 'zh-CN'
    ? `${systemInstruction}\n\n以下是用户的${systemName}排盘数据：\n\`\`\`json\n${chartJson}\n\`\`\`\n\n请用${langWord}给出完整结构化解读（800-1500 字）。覆盖六大维度：\n1. 性格与天赋\n2. 事业与学业\n3. 财运\n4. 感情与人际关系\n5. 健康\n6. 流年与近期趋势（未来 6-12 个月）\n\n每个维度给 2-3 句具体观察，呼应排盘数据而非泛泛而谈。`
    : `${systemInstruction}\n\nHere is the user's ${systemName} chart data:\n\`\`\`json\n${chartJson}\n\`\`\`\n\nReply in ${langWord} (800-1500 words / characters). Cover six dimensions:\n1. Personality & innate talents\n2. Career & studies\n3. Wealth\n4. Love & relationships\n5. Health\n6. Annual / near-term trend (next 6-12 months)\n\nEach dimension: 2-3 specific observations that explicitly reference the chart data above.`;

  return { prompt: userPrompt, model: pickModel(tier, locale), maxTokens: 6000 };
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
