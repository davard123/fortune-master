// supabase/functions/chart-bazi/index.ts
// POST /functions/v1/chart-bazi
// 调用 taibu-core/bazi 进行八字排盘. Tier 0 (免费).
//
// Privacy: input.birth_lat / birth_lng 在排盘完后立即清除, 不入 readings.input_payload.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
// deno-lint-ignore no-explicit-any
declare const Deno: any;

interface BaziRequest {
  birthYear: number;
  birthMonth: number;
  birthDay: number;
  birthHour: number;
  gender: 'male' | 'female' | 'other';
  // 不需要 birth_lat/birth_lng - 八字只需要日期+时间
  // 不需要 timezone - 默认 Local; 如需高级, 改 taibu-core timezone 包装
}

interface BaziResponse {
  chart_data: Record<string, unknown>;
  system: 'bazi';
  computedAt: string;
}

serve(async (req) => {
  // CORS
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
    const body: BaziRequest = await req.json();

    // 参数校验
    if (!body.birthYear || !body.birthMonth || !body.birthDay) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 调用 taibu-core (npm 包, 在 Supabase Edge Function 通过 esm.sh 引入)
    // 备注: Supabase Edge Function 支持 npm: 协议 (Deno 1.40+)
    const { calculateBazi } = await import('npm:taibu-core@^3.4.0/bazi');

    const chart = calculateBazi({
      birthYear: body.birthYear,
      birthMonth: body.birthMonth,
      birthDay: body.birthDay,
      birthHour: body.birthHour || 0,
      gender: body.gender,
    });

    const response: BaziResponse = {
      chart_data: chart,
      system: 'bazi',
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

// deno-lint-ignore no-unused-vars
const _sb_dummy = Deno;
