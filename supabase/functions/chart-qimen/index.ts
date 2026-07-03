// supabase/functions/chart-qimen/index.ts
// POST /functions/v1/chart-qimen
// 奇门遁甲排盘. Tier 0 (免费).
//
// 2026-07-02 修订: 不再调用 taibu-core/qimen。
//   原因: taibu-core 的 calculateQimen 内部依赖真实修改 process.env.TZ 才能
//   正确解析非 UTC 的墙钟时间（库自己的源码注释也承认 "zonedWallClockToSystemDate
//   无法替代"）。Supabase Edge Runtime 禁止运行时改环境变量，导致奇门结果的
//   日柱/时柱天干在实测中被证实算错（与 lunar-javascript 直接计算的权威结果不一致）。
//   这是 taibu-core 库本身的架构限制，不是参数传法问题，无法在调用方打补丁修复。
//
//   改为: 自实现拆补法排盘 (见 ../_shared/qimen-native.ts)，四柱直接用
//   lunar-javascript (纯历法计算，不依赖系统时区，和八字模块同一套算法)。
//
//   置信度: 四柱/局数判定/地盘排列已用一个完整实例逐宫验证通过；值符值使定位、
//   天盘九星与人盘八门的旋转方向仍是中等置信度 (中文资料对旋转方向存在流派分歧)。
//   详见 qimen-native.ts 文件头注释。上线前建议找一个可信的奇门排盘工具逐宫核对。
//
//   详见 docs/incidents/2026-07-01-taibu-core-qimen-empty.md。

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { handleCorsPreflight, jsonResponse } from '../_shared/cors.ts';
import { calculateQimenNative } from '../_shared/qimen-native.ts';

interface QimenRequest {
  datetime?: string;
  question?: string;
  year?: number;
  month?: number;
  day?: number;
  hour?: number;
  minute?: number;
}

// 从 ISO 字符串解析"墙钟时间"字面量 (不管带不带 +08:00 偏移, 都当作字面量直接用,
// 与八字模块一致 —— lunar-javascript 是纯历法计算, 不需要真实换算时区).
function parseWallClock(iso: string) {
  const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})/);
  if (!m) return null;
  return { year: +m[1], month: +m[2], day: +m[3], hour: +m[4], minute: +m[5] };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return handleCorsPreflight(req);
  if (req.method !== 'POST') {
    return jsonResponse(req, { error: 'Method not allowed' }, 405);
  }

  try {
    const body: QimenRequest = await req.json().catch(() => ({}));

    let wall: { year: number; month: number; day: number; hour: number; minute: number } | null = null;
    if (body.datetime) {
      wall = parseWallClock(body.datetime);
    } else if (body.year && body.month && body.day && body.hour !== undefined) {
      wall = {
        year: body.year,
        month: body.month,
        day: body.day,
        hour: body.hour,
        minute: body.minute ?? 0,
      };
    }
    if (!wall) {
      return jsonResponse(
        req,
        { error: 'Provide {datetime: ISO string} or {year, month, day, hour[, minute]}' },
        400,
      );
    }

    const { Solar } = await import('npm:lunar-javascript@^1.7.7');
    const chart = calculateQimenNative({ ...wall, question: body.question }, { Solar });

    return jsonResponse(req, {
      chart_data: chart,
      system: 'qimen',
      computedAt: new Date().toISOString(),
    });
  } catch (e) {
    return jsonResponse(
      req,
      { error: e instanceof Error ? e.message : 'Unknown error' },
      500,
    );
  }
});
