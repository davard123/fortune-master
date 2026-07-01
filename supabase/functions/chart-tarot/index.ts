// supabase/functions/chart-tarot/index.ts
// POST /functions/v1/chart-tarot
// 调用 taibu-core/tarot (复用其 78 张牌数据) 进行塔罗抽牌. Tier 0 (免费).

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

interface TarotRequest {
  spread: 'one' | 'three' | 'celtic';
  question?: string;       // 用户问题 (可选, 仅 LLM 解读时用)
  deckName?: string;       // 默认 'rider-waite'
  randomSeed?: number;     // 可选: 测试时固定随机
}

interface TarotCard {
  name: string;
  en: string;
  upright: boolean;
  position: number;        // 0-indexed
  positionLabel: string;   // '过去' | '现在' | '未来' | ...
  keywords: string[];
}

interface TarotResponse {
  cards: TarotCard[];
  spread: string;
  deckName: string;
  computedAt: string;
}

const SPREAD_LAYOUTS: Record<string, string[]> = {
  one: ['当前'],
  three: ['过去', '现在', '未来'],
  celtic: [
    '当前状况', '挑战', '根基', '过去', '顶点', '未来',
    '自我', '环境', '希望与恐惧', '结果',
  ],
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
    const spread = body.spread || 'three';
    const deckName = body.deckName || 'rider-waite';
    const layout = SPREAD_LAYOUTS[spread];

    if (!layout) {
      return new Response(JSON.stringify({ error: `Unknown spread: ${spread}` }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 调用 taibu-core/tarot
    // 注: taibu-core 内部已包含 78 张 Rider-Waite 牌面数据
    const tarotModule = await import('npm:taibu-core@^3.4.0/tarot');
    const cards = tarotModule.drawCards
      ? tarotModule.drawCards({ count: layout.length, seed: body.randomSeed })
      : tarotModule.draw({ count: layout.length, seed: body.randomSeed });

    const positioned: TarotCard[] = cards.map((c: any, idx: number) => ({
      name: c.name_zh || c.nameCN || c.name,
      en: c.name_en || c.nameEN || c.name,
      upright: c.upright !== undefined ? c.upright : Math.random() > 0.5,
      position: idx,
      positionLabel: layout[idx],
      keywords: c.keywords || [],
    }));

    const response: TarotResponse = {
      cards: positioned,
      spread,
      deckName,
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
