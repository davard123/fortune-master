// supabase/functions/interpret/index.ts
// POST /functions/v1/interpret
// 基于排盘结果生成 LLM 解读 (Tier 1 brief / Tier 2 detailed).
// Provider: FreeLLMAPI (试用) → DeepSeek (生产), 由 FREELLMAPI_URL/KEY 或
//                          DEEPSEEK_API_KEY 切换，详见 README.md.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface InterpretRequest {
  system: 'bazi' | 'tarot' | 'qimen' | 'ziwei' | 'iching';
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
};

const SYSTEM_NAME_EN: Record<string, string> = {
  bazi: 'Bazi (Four Pillars)',
  tarot: 'Tarot',
  qimen: 'Qimen Dunjia',
  ziwei: 'Zi Wei Dou Shu',
  iching: 'I Ching',
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

    if (body.locale !== 'en' && body.locale !== 'zh-CN') {
      return jsonResponse(req, { error: 'locale must be "en" or "zh-CN"' }, 400);
    }

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
    const interpretation: string = data?.choices?.[0]?.message?.content?.trim() ?? '';

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

  if (tier === 'brief') {
    const userPrompt = locale === 'zh-CN'
      ? `${systemInstruction}\n\n以下是用户的${systemName}排盘数据：\n\`\`\`json\n${chartJson}\n\`\`\`\n\n请用${langWord}给出一段 ≤200 字的精炼解读，覆盖 3 个要点：\n• 性格核心特征（2 句话）\n• 当前运势核心提示（1 句话）\n• 一句可执行的温和建议`
      : `${systemInstruction}\n\nHere is the user's ${systemName} chart data:\n\`\`\`json\n${chartJson}\n\`\`\`\n\nReply in ${langWord} (≤200 words / about 200 characters). Cover three points:\n• Core personality trait (2 sentences)\n• Key current trend (1 sentence)\n• One gentle, actionable suggestion`;

    return { prompt: userPrompt, model: pickModel(tier, locale), maxTokens: 500 };
  }

  const userPrompt = locale === 'zh-CN'
    ? `${systemInstruction}\n\n以下是用户的${systemName}排盘数据：\n\`\`\`json\n${chartJson}\n\`\`\`\n\n请用${langWord}给出完整结构化解读（800-1500 字）。覆盖六大维度：\n1. 性格与天赋\n2. 事业与学业\n3. 财运\n4. 感情与人际关系\n5. 健康\n6. 流年与近期趋势（未来 6-12 个月）\n\n每个维度给 2-3 句具体观察，呼应排盘数据而非泛泛而谈。`
    : `${systemInstruction}\n\nHere is the user's ${systemName} chart data:\n\`\`\`json\n${chartJson}\n\`\`\`\n\nReply in ${langWord} (800-1500 words / characters). Cover six dimensions:\n1. Personality & innate talents\n2. Career & studies\n3. Wealth\n4. Love & relationships\n5. Health\n6. Annual / near-term trend (next 6-12 months)\n\nEach dimension: 2-3 specific observations that explicitly reference the chart data above.`;

  return { prompt: userPrompt, model: pickModel(tier, locale), maxTokens: 2000 };
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
