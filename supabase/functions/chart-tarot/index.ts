// supabase/functions/chart-tarot/index.ts
// POST /functions/v1/chart-tarot
// 调用 taibu-core/tarot 进行塔罗抽牌. Tier 0 (免费).
//
// 外部别名映射: 'one' | 'three' | 'celtic' →
//   taibu-core spreadType: 'single' | 'three-card' | 'celtic-cross'
// 不传 seed (避免已知的 trim bug, 让 taibu-core 自己生成).

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface TarotRequest {
  spread?: 'one' | 'three' | 'celtic';
  question?: string;
  birthYear?: number;
  birthMonth?: number;
  birthDay?: number;
}

interface TarotResponse {
  cards: Array<{
    position: number;
    positionLabel: string;
    name: string;
    nameEn: string;
    upright: boolean;
    orientation: string;
    keywords: string[];
    meaning: string;
  }>;
  spread: string;
  spreadInternal: string;
  computedAt: string;
}

const SPREAD_ALIAS: Record<string, { internal: string; positions: string[] }> = {
  one:    { internal: 'single',       positions: ['当前'] },
  three:  { internal: 'three-card',   positions: ['过去', '现在', '未来'] },
  celtic: { internal: 'celtic-cross', positions: ['现状', '挑战', '根基', '近期过去', '冠冕', '近期未来', '自我', '外部', '希望与恐惧', '结果'] },
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
declare const Deno: any;

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: TarotRequest = await req.json();
    const spreadKey = body.spread || 'three';
    const mapping = SPREAD_ALIAS[spreadKey];

    if (!mapping) {
      return jsonResponse(
        req,
        { error: `Unknown spread: ${spreadKey}. Valid: one, three, celtic` },
        400,
      );
    }

    const { calculateTarot } = await import('npm:taibu-core@^3.4.0/tarot');

    const result = await calculateTarot({
      spreadType: mapping.internal,
      question: body.question,
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

    return jsonResponse(req, response);
  } catch (e) {
    return jsonResponse(
      req,
      { error: e instanceof Error ? e.message : 'Unknown error' },
      500,
    );
  }
});
