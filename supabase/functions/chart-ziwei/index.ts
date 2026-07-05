// supabase/functions/chart-ziwei/index.ts
// POST /functions/v1/chart-ziwei — 紫微斗数排盘 (taibu-core). Tier 0 (免费).
// TZ 安全性: 2026-07-04 已验证 calculateZiwei 在 China TZ 与 UTC 下输出一致.
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface ZiweiRequest {
  birthYear: number;
  birthMonth: number;
  birthDay: number;
  birthHour: number;
  birthMinute?: number;
  gender: 'male' | 'female' | 'other';
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: ZiweiRequest = await req.json().catch(() => ({} as ZiweiRequest));
    if (!body.birthYear || !body.birthMonth || !body.birthDay || body.birthHour === undefined) {
      return jsonResponse(req, { error: 'Missing required fields: birthYear/birthMonth/birthDay/birthHour' }, 400);
    }

    const { calculateZiwei } = await import('npm:taibu-core@^3.4.0/ziwei');
    const chart = await calculateZiwei({
      birthYear: body.birthYear,
      birthMonth: body.birthMonth,
      birthDay: body.birthDay,
      birthHour: body.birthHour,
      birthMinute: body.birthMinute ?? 0,
      gender: body.gender === 'female' ? 'female' : 'male',
    });

    return jsonResponse(req, {
      chart_data: chart,
      system: 'ziwei',
      computedAt: new Date().toISOString(),
    });
  } catch (e) {
    return jsonResponse(req, { error: e instanceof Error ? e.message : 'Unknown error' }, 500);
  }
});
