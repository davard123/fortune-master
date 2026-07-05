// supabase/functions/chart-liuyao/index.ts
// POST /functions/v1/chart-liuyao — 周易六爻起卦 (taibu-core). Tier 0 (免费).
// TZ 安全性: 2026-07-04 已验证 calculateLiuyao 在 China TZ 与 UTC 下输出一致
// (固定 seed 时; 不传 seed 为服务端随机摇卦, 属预期行为).
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';

interface LiuyaoRequest {
  question: string;
  /// 分析目标 (六亲), 如 ['官鬼','妻财']. taibu-core 要求至少一个, 缺省给通用组合.
  yongShenTargets?: string[];
  method?: 'auto' | 'time' | 'number';
  numbers?: number[];
  datetime?: string; // "YYYY-MM-DD HH:mm", 默认当前 UTC 墙钟 (自测阶段可接受)
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: LiuyaoRequest = await req.json().catch(() => ({} as LiuyaoRequest));
    if (!body.question || !body.question.trim()) {
      return jsonResponse(req, { error: 'question is required' }, 400);
    }

    const now = new Date();
    const pad = (n: number) => String(n).padStart(2, '0');
    const date = body.datetime ??
      `${now.getUTCFullYear()}-${pad(now.getUTCMonth() + 1)}-${pad(now.getUTCDate())} ${pad(now.getUTCHours())}:${pad(now.getUTCMinutes())}`;

    const { calculateLiuyao } = await import('npm:taibu-core@^3.4.0/liuyao');
    const chart = await calculateLiuyao({
      question: body.question.trim(),
      // taibu-core 硬性要求至少一个用神目标; 客户端不传时给覆盖面最广的组合
      yongShenTargets: (body.yongShenTargets && body.yongShenTargets.length > 0)
        ? body.yongShenTargets
        : ['官鬼', '妻财', '父母', '兄弟', '子孙'],
      method: body.method ?? 'auto',
      numbers: body.numbers,
      date,
    });

    return jsonResponse(req, {
      chart_data: chart,
      system: 'iching',
      computedAt: new Date().toISOString(),
    });
  } catch (e) {
    return jsonResponse(req, { error: e instanceof Error ? e.message : 'Unknown error' }, 500);
  }
});
