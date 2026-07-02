// supabase/functions/chart-qimen/index.ts
// POST /functions/v1/chart-qimen
// 验证 taibu-core/qimen 在 Deno 环境的 Bug (incident 2026-07-01-taibu-core-qimen-empty.md).
//
// 已知 (Node 24.14.0 验证): taibu-core/qimen 在传 datetime 时返回 {}.
// 本函数目的: 在 Deno 2.9.0 (Supabase Edge Runtime) 重新验证, 确认是否跨运行时.
//
// 调用: POST { "datetime": "2026-07-01T14:30:00+08:00", "lang": "zh-CN" }

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

interface QimenRequest {
  datetime?: string;          // ISO 字符串, 默认当前时间
  lang?: 'zh-CN' | 'en';
}

interface QimenResponse {
  chart_data: Record<string, unknown>;
  system: 'qimen';
  computedAt: string;
  debug?: {
    runtime: string;
    taibuQimenKeys: string[];
    rawReturnIsEmpty: boolean;
    rawReturnKeys: string[];
  };
}

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
    const body: QimenRequest = await req.json().catch(() => ({}));
    const datetime = body.datetime || new Date().toISOString();
    const lang = body.lang || 'zh-CN';

    // 探针 1: 列出 taibu-core/qimen 所有导出
    const qimenModule = await import('npm:taibu-core@^3.4.0/qimen');
    const moduleKeys = Object.keys(qimenModule);

    // 探针 2: 找主函数 (尝试多个常见名字)
    let chart: any = {};
    let usedFn: string | null = null;
    const candidates = ['calculateQimen', 'calculate', 'getQimen', 'compute', 'pan', 'draw'];
    for (const name of candidates) {
      const fn = qimenModule[name];
      if (typeof fn === 'function') {
        try {
          chart = await fn({ datetime, lang });
          usedFn = name;
          break;
        } catch (e) {
          // 这个 candidate 失败, 继续试下一个
          continue;
        }
      }
    }

    const isEmpty = !chart || (typeof chart === 'object' && Object.keys(chart).length === 0);
    const chartKeys = chart && typeof chart === 'object' ? Object.keys(chart) : [];

    const response: QimenResponse = {
      chart_data: chart || {},
      system: 'qimen',
      computedAt: new Date().toISOString(),
      debug: {
        runtime: 'deno-' + Deno.version.deno,
        taibuQimenKeys: moduleKeys,
        rawReturnIsEmpty: isEmpty,
        rawReturnKeys: chartKeys,
      },
    };

    return new Response(JSON.stringify(response), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({
        error: e instanceof Error ? e.message : 'Unknown error',
        stack: e instanceof Error ? e.stack : undefined,
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});