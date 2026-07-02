// supabase/functions/chart-tarot/index.ts
// POST /functions/v1/chart-tarot
// 调用 taibu-core/tarot 进行塔罗抽牌. Tier 0 (免费).
//
// API 调研结果 (2026-07-01 验证):
//   taibu-core/tarot 导出: { TAROT_CARDS, TAROT_SPREADS, calculateTarot, toTarotJson, toTarotText }
//   calculateTarot({ spreadType: 'single' | 'three-card' | 'celtic-cross' | 'love' | 'horseshoe' | 'decision' })
//   返回: { spreadId, spreadName, seed, cards: [{ position, card: { name, nameChinese, keywords }, orientation, meaning }] }
//
// 注意: taibu-core/tarot 的 spread id 不是 'one'/'three'/'celtic', 而是
//   'single' / 'three-card' / 'celtic-cross', 这里做了外部别名映射.
//
// 已发现的 taibu-core bug (incident 2026-07-01-b): seed 传数字会触发
//   "inputSeed?.trim is not a function". 我们不传 seed, 让 taibu-core 自己生成.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

interface TarotRequest {
  spread?: 'one' | 'three' | 'celtic';  // 外部别名
  question?: string;
  birthYear?: number;
  birthMonth?: number;
  birthDay?: number;
}

interface TarotResponse {
  cards: Array<{
    position: number;
    positionLabel: string;
    name: string;             // 优先中文
    nameEn: string;
    upright: boolean;
    orientation: string;      // 'upright' | 'reversed'
    keywords: string[];
    meaning: string;
  }>;
  spread: string;             // 外部 spread id
  spreadInternal: string;     // taibu-core spreadId
  computedAt: string;
}

// 外部别名 → taibu-core spreadType
const SPREAD_ALIAS: Record<string, { internal: string; positions: string[] }> = {
  one:    { internal: 'single',         positions: ['当前'] },
  three:  { internal: 'three-card',     positions: ['过去', '现在', '未来'] },
  celtic: { internal: 'celtic-cross',   positions: ['现状', '挑战', '根基', '近期过去', '冠冕', '近期未来', '自我', '外部', '希望与恐惧', '结果'] },
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const body: TarotRequest = await req.json();
    const spreadKey = body.spread || 'three';
    const mapping = SPREAD_ALIAS[spreadKey];

    if (!mapping) {
      return new Response(JSON.stringify({ error: `Unknown spread: ${spreadKey}. Valid: one, three, celtic` }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 调 taibu-core
    const { calculateTarot } = await import('npm:taibu-core@^3.4.0/tarot');

    const result = await calculateTarot({
      spreadType: mapping.internal,
      question: body.question,
      // 不传 seed, 避免触发已知的 trim bug
      // 提供生日可获得生命牌 / 灵魂牌 / 年度牌 (可选)
      birthYear: body.birthYear,
      birthMonth: body.birthMonth,
      birthDay: body.birthDay,
    });

    const cards = (result.cards || []).map((c: any, idx: number) => ({
      position: idx,
      positionLabel: c.position || mapping.positions[idx] || '',
      name: c.card?.nameChinese || c.card?.name || '',
      nameEn: c.card?.name || '',
      upright: c.orientation === 'upright',
      orientation: c.orientation,
      keywords: c.card?.keywords || [],
      meaning: c.meaning || '',
    }));

    const response: TarotResponse = {
      cards,
      spread: spreadKey,
      spreadInternal: result.spreadId,
      computedAt: new Date().toISOString(),
    };

    return new Response(JSON.stringify(response), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e instanceof Error ? e.message : 'Unknown error' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});