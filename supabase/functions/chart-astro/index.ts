// supabase/functions/chart-astro/index.ts
// POST /functions/v1/chart-astro — 西方占星本命盘 (taibu-core). Tier 0 (免费).
// TZ 安全性: 2026-07-04 已验证 calculateAstrology 在 China TZ 与 UTC 下输出一致
// (时区由经纬度推导, 内部用 Intl 显式时区计算, 不依赖系统时区).
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface AstroRequest {
  birthYear: number;
  birthMonth: number;
  birthDay: number;
  birthHour: number;
  birthMinute?: number;
  latitude?: number;   // 默认北京
  longitude?: number;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: AstroRequest = await req.json().catch(() => ({} as AstroRequest));
    if (!body.birthYear || !body.birthMonth || !body.birthDay || body.birthHour === undefined) {
      return jsonResponse(req, { error: 'Missing required fields: birthYear/birthMonth/birthDay/birthHour' }, 400);
    }

    const { calculateAstrology } = await import('npm:taibu-core@^3.4.0/astrology');
    const chart = await calculateAstrology({
      birthYear: body.birthYear,
      birthMonth: body.birthMonth,
      birthDay: body.birthDay,
      birthHour: body.birthHour,
      birthMinute: body.birthMinute ?? 0,
      latitude: body.latitude ?? 39.9,
      longitude: body.longitude ?? 116.4,
    });

    // 隐私: 精确经纬度用完即弃 — 返回结果里 natal.origin 已含 taibu 的回显,
    // 客户端不持久化; 服务器端本函数无任何存储.
    return jsonResponse(req, {
      chart_data: chart,
      system: 'astro',
      computedAt: new Date().toISOString(),
    });
  } catch (e) {
    return jsonResponse(req, { error: e instanceof Error ? e.message : 'Unknown error' }, 500);
  }
});
