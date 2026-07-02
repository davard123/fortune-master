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
