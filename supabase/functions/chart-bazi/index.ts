// supabase/functions/chart-bazi/index.ts
// POST /functions/v1/chart-bazi
// 调用 taibu-core/bazi 进行八字排盘. Tier 0 (免费).
//
// Privacy: input.birth_lat / birth_lng 在排盘完后立即清除, 不入 readings.input_payload.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { buildCorsHeaders, handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface BaziRequest {
  birthYear: number;
  birthMonth: number;
  birthDay: number;
  birthHour: number;
  gender: 'male' | 'female' | 'other';
}

interface BaziResponse {
  chart_data: Record<string, unknown>;
  system: 'bazi';
  computedAt: string;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
declare const Deno: any;

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: BaziRequest = await req.json();

    if (!body.birthYear || !body.birthMonth || !body.birthDay) {
      return jsonResponse(req, { error: 'Missing required fields' }, 400);
    }

    const input = {
      birthYear: body.birthYear,
      birthMonth: body.birthMonth,
      birthDay: body.birthDay,
      birthHour: body.birthHour || 0,
      gender: body.gender,
    };

    const { calculateBazi, calculateBaziFiveElementsStats } = await import(
      'npm:taibu-core@^3.4.0/bazi'
    );
    const chart = calculateBazi(input) as Record<string, unknown>;

    // 大运 (十年一运, 含起运年份) —— 长期运势预测的核心原料.
    // 五行强弱统计 —— 用神喜忌分析的原料. 任一失败不阻塞基础排盘.
    try {
      const { calculateBaziDayun } = await import(
        'npm:taibu-core@^3.4.0/bazi-dayun'
      );
      chart.dayun = await calculateBaziDayun(input);
    } catch (_e) { /* 大运失败不阻塞 */ }
    try {
      // 注意: 该函数吃的是排盘结果里的 fourPillars, 不是原始 input
      chart.fiveElementsStats = calculateBaziFiveElementsStats(
        (chart as { fourPillars: unknown }).fourPillars,
      );
    } catch (_e) { /* 五行统计失败不阻塞 */ }

    // 出生信息回显: LLM 解读需要据此结合"当前日期"计算实际年龄/定位当前大运.
    // 只含日期与性别, 不含任何经纬度 (隐私原则).
    chart.birthInfo = {
      solarDate:
        `${body.birthYear}-${String(body.birthMonth).padStart(2, '0')}-${String(body.birthDay).padStart(2, '0')}`,
      birthHour: body.birthHour || 0,
      gender: body.gender,
    };

    const response: BaziResponse = {
      chart_data: chart,
      system: 'bazi',
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

// Suppress unused import warning for buildCorsHeaders — kept for future use.
// eslint-disable-next-line @typescript-eslint/no-unused-vars
void buildCorsHeaders;
