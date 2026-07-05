// supabase/functions/chart-meihua/index.ts
// POST /functions/v1/chart-meihua — 梅花易数起卦 (taibu-core). Tier 0 (免费).
// TZ 安全性: 2026-07-04 已验证 calculateMeihua 在 China TZ 与 UTC 下输出一致.
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface MeihuaRequest {
  question: string;
  method?: 'time' | 'number';
  numbers?: number[];
  datetime?: string; // "YYYY-MM-DD HH:mm"; 时间起卦的基准, 默认当前 UTC 墙钟
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: MeihuaRequest = await req.json().catch(() => ({} as MeihuaRequest));
    if (!body.question || !body.question.trim()) {
      return jsonResponse(req, { error: 'question is required' }, 400);
    }

    const now = new Date();
    const pad = (n: number) => String(n).padStart(2, '0');
    const date = body.datetime ??
      `${now.getUTCFullYear()}-${pad(now.getUTCMonth() + 1)}-${pad(now.getUTCDate())} ${pad(now.getUTCHours())}:${pad(now.getUTCMinutes())}`;

    const { calculateMeihua } = await import('npm:taibu-core@^3.4.0/meihua');
    const chart = await calculateMeihua({
      question: body.question.trim(),
      date,
      method: body.method ?? 'time',
      numbers: body.numbers,
    });

    return jsonResponse(req, {
      chart_data: chart,
      system: 'meihua',
      computedAt: new Date().toISOString(),
    });
  } catch (e) {
    return jsonResponse(req, { error: e instanceof Error ? e.message : 'Unknown error' }, 500);
  }
});
