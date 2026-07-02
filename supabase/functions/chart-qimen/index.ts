// supabase/functions/chart-qimen/index.ts
// POST /functions/v1/chart-qimen
// 调用 taibu-core/qimen 进行奇门遁甲排盘. Tier 0 (免费).
//
// 2026-07-01 修订 (用户复核实测后):
//   原"qimen 返回 {} 跨运行时 bug"已证伪. taibu-core 没有缺陷.
//   真实原因:
//     1. calculateQimen 返回 Promise, 必须 await
//     2. 入参形状是 {year, month, day, hour[, minute]}, 不是 {datetime, lang}
//   本实装已修正两个错误.
//   详见 docs/incidents/2026-07-01-taibu-core-qimen-empty.md 结案.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

interface QimenRequest {
  datetime?: string;     // ISO 字符串, 如 "2026-07-01T14:30:00+08:00" (前端友好)
  question?: string;
  // 也可直传:
  // year, month, day, hour, minute
  year?: number;
  month?: number;
  day?: number;
  hour?: number;
  minute?: number;
}

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Content-Type': 'application/json',
};

// 从 ISO 字符串解析"墙钟时间"字面量
// Edge Runtime 是 UTC, new Date(y,m-1,d,h,min) 的本地 getter 返回传入数字
// 所以"用户本地 14:30"等价于"机器 UTC 14:30" —— 巧合正确, 不需要时区切换
function parseWallClock(iso: string) {
  const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})/);
  if (!m) return null;
  return { year: +m[1], month: +m[2], day: +m[3], hour: +m[4], minute: +m[5] };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });

  try {
    const body: QimenRequest = await req.json().catch(() => ({}));

    // 解析入参: 优先 ISO datetime, 回落到 year/month/day/hour
    let wall = null;
    if (body.datetime) {
      wall = parseWallClock(body.datetime);
    } else if (body.year && body.month && body.day && body.hour !== undefined) {
      wall = { year: body.year, month: body.month, day: body.day, hour: body.hour, minute: body.minute ?? 0 };
    }
    if (!wall) {
      return new Response(
        JSON.stringify({ error: 'Provide {datetime: ISO string} or {year, month, day, hour[, minute]}' }),
        { status: 400, headers: CORS },
      );
    }

    // 调 taibu-core —— 必须 await!
    const { calculateQimen } = await import('npm:taibu-core@^3.4.0/qimen');
    const chart = await calculateQimen({ ...wall, question: body.question });

    return new Response(
      JSON.stringify({ chart_data: chart, system: 'qimen', computedAt: new Date().toISOString() }),
      { headers: CORS },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e instanceof Error ? e.message : 'Unknown error' }),
      { status: 500, headers: CORS },
    );
  }
});