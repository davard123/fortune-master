# Incident: taibu-core 奇门排盘 "返回空对象" — **已结案，误诊**

**日期**：2026-07-01
**发现人**：davard123（通过 Claude 自动化验证）
**严重度**：🟢 **已结案，无 bug**（初始 🔴 误判为 taibu-core 缺陷）
**结案人**：davard123（用户复核实测证伪）
**结案时间**：2026-07-01 18:55 PDT

---

## TL;DR

**taibu-core/qimen 没有 bug**。所谓"返回 `{}`"是**两个独立错误叠加**造成的误诊：

1. **未 `await`**：`calculateQimen()` 返回 `Promise`，对 pending Promise 取 `Object.keys()` 得空数组 `[]`（看起来就像空对象）
2. **参数形状错误**：传 `{datetime: "ISO 字符串", lang}` 不是 taibu-core/qimen 的入参形状（应传 `{year, month, day, hour, minute?}`），taibu 内部抛 "arg can't be use"，被外层 try/catch 吞掉，chart 保持初始 `{}`

正确用法：
```ts
const chart = await calculateQimen({ year: 2026, month: 7, day: 1, hour: 14, minute: 30 });
// 返回完整 16 字段, 9 宫, yin dun, ju 6, 值符天芮, 值使死门, 5 个全局格局
```

---

## 误诊时间线

### Step 1: Node 24 验证（错的）

**现象**：`Object.keys(calculateQimen({...}))` 返回 `[]`

**当时推断**：以为 taibu-core 内部修改 `process.env.TZ` 后 V8 Date 缓存旧 offset 导致返回空（"可能 1/2/3"）。

**真实原因**：忘 `await`，对 pending Promise 取 keys 就是空数组。

### Step 2: Deno 验证（错的）

**chart-qimen/index.ts 部署后 curl**：
```bash
curl -X POST .../chart-qimen -d '{"datetime":"2026-07-01T14:30:00+08:00","lang":"zh-CN"}'
# 返回: {"chart_data":{}, ...}
```

**当时推断**：Deno 也复现，是 taibu-core 自身 bug，需自实现 fallback。

**真实原因**：传 `{datetime, lang}` 是错的入参形状，taibu 内部抛错被 try/catch 吞掉，chart 保持初始 `{}`。

### Step 3: 用户复核（2026-07-01 18:50）

用户实测三种调用方式：

| 调用方式 | 结果 |
|---------|------|
| `await calculateQimen({year, month, day, hour, minute})` | ✅ **完整 16 字段、9 宫、局数 6** |
| 同样参数但忘了 await | `Object.keys(r)=[]` —— pending Promise 的 keys 就是空数组 |
| 传 `{datetime: "ISO 字符串", lang}` | 抛错 "奇门排盘失败: arg can\`t be use" |

phase1-implementation-plan.md §1.4 里原本就写着 qimen 用 `year/month/day/hour(/minute)`，当时没照做。

---

## 已废弃的 Workaround 方案

| 方案 | 状态 |
|------|------|
| **A**: 时区偏移包装层 | ❌ 废弃（bug 不存在） |
| **B**: 自实现 qimen-fallback 包（~200-300 行 TS） | ❌ **完全废弃**，是 P0 #2 但根因错了 |
| **C**: 在 Deno 上验证 | ❌ 误导性结论（Deno 也"复现"是因为同样的代码错误） |

---

## 正确的 API 用法（参考）

```ts
// 最小调用
const chart = await calculateQimen({
  year: 2026, month: 7, day: 1, hour: 14, minute: 30,
});

// 可选: 带问题（用于后续 AI 解读）
const chart2 = await calculateQimen({
  year: 2026, month: 7, day: 1, hour: 14, minute: 30,
  question: '今日适合签约吗？',
});
```

**返回字段**（实测 2026-07-01 14:30）：
```json
{
  "dateInfo": { "solarDate", "lunarDate", "solarTerm", "solarTermRange" },
  "siZhu": { "year", "month", "day", "hour" },
  "dunType": "yin",                  // 阴遁
  "juNumber": 6,                      // 6 局
  "yuan": "下元",
  "xunShou": "甲辰",
  "zhiFu": { "star": "天芮星", "palace": 9 },
  "zhiShi": { "gate": "死门", "palace": 2 },
  "palaces": [ /* 9 个宫, 每个含天盘/地盘/九星/八门/八神/格局/旺衰/空亡/驿马/入墓 */ ],
  "kongWang": { "dayKong": {...}, "hourKong": {...} },
  "yiMa": { "branch": "亥", "palace": 6 },
  "globalFormations": [ "坎宫: 蛇矫入火", "巽宫: 太白入荧", "乾宫: 刑格", "兑宫: 日出扶桑", "离宫: 地遁" ],
  "panType": "转盘",
  "juMethod": "拆补法",
  "monthPhase": { "甲": "休", ..., "癸": "囚" }
}
```

---

## Supabase Edge Function 实装经验（chart-qimen）

Deno 部署成功的关键：

1. **Edge Runtime 是 UTC**（不是 Asia/Shanghai）—— `new Date().getTimezoneOffset()` 返回 0
2. **Deno 禁止环境变量写入** —— taibu 内部修改 `process.env.TZ` 不会生效，但 UTC 运行时下本来就是 UTC，**无需任何 workaround**
3. **`new Date(y, m-1, d, h, min)` 在 UTC 环境下返回的本地 getter 就是传入的墙钟数字**，所以"用户传入 14:30"等价于"机器就在 UTC 14:30"——巧合地正确

简化后的 chart-qimen 实装（最终版）：

```ts
// supabase/functions/chart-qimen/index.ts
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

interface QimenRequest {
  datetime?: string;       // ISO, 如 "2026-07-01T14:30:00+08:00"
  question?: string;
}

function parseWallClock(iso: string) {
  const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})/);
  if (!m) return null;
  return {
    year: +m[1], month: +m[2], day: +m[3],
    hour: +m[4], minute: +m[5],
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const body: QimenRequest = await req.json().catch(() => ({}));
    if (!body.datetime) return new Response(JSON.stringify({ error: 'datetime required (ISO)' }), { status: 400 });
    const wall = parseWallClock(body.datetime);
    if (!wall) return new Response(JSON.stringify({ error: 'Invalid datetime format' }), { status: 400 });

    const { calculateQimen } = await import('npm:taibu-core@^3.4.0/qimen');
    const chart = await calculateQimen({ ...wall, question: body.question });
    // ↑ 注意 await - 这才是上次 bug 的根因

    return new Response(JSON.stringify({ chart_data: chart, system: 'qimen', computedAt: new Date().toISOString() }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 });
  }
});
```

---

## 教训

1. **Promise 必须 await**——对未 await 的 Promise 取 `Object.keys()` 永远返回 `[]`，容易误诊为空对象
2. **API 入参形状要对**——传错字段名（如 `datetime` 而非 `year/month/day`）会被静默 try/catch 吞掉
3. **遇到"返回空对象"先做控制台探针**——打印完整对象而不只是 keys，确认是 `{}` 还是 `Promise<{}>`
4. **不要在没 await 的前提下断言函数"返回空"**——这是经典 JS 陷阱
5. **外部 API 错误时不要立刻判定上游 bug**——大概率是调用姿势不对

---

## 影响范围（修订）

| 术数 | Phase 1 影响 |
|------|---------------|
| 八字 | ✅ OK（Deno + Node 均验证）|
| 紫微 | ⚠️ 待验证（已决定继续用 taibu-core calculateZiwei） |
| 奇门 | ✅ OK（Deno 验证完整 9 宫返回）**前提：用正确 API + await** |
| 西占星 | ✅ OK（Node 验证） |
| 塔罗 | ✅ OK（Deno 验证，spread 别名映射） |
| 六爻 / 梅花 / 太乙 / 大六壬 / 小六壬 | ⚠️ 待逐一验证，但**应先 await** |
| 周公解梦 | ✅ 自建，无依赖 |

---

## 相关错误（同类陷阱）

| 模块 | "Bug" | 真实原因 |
|------|------|---------|
| tarot `seed` 数字 | `inputSeed?.trim is not a function` | 传数字 → `5?.trim()` 当然报错。传 **字符串** `'123'` 就正常 |
| qimen `datetime` | 抛错 `arg can't be use` | datetime 不是 qimen 入参，应为 `{year, month, day, hour, minute}` |

**这两个"bug"都是同一类误诊：API 入参形状/类型不对，不是 taibu-core 缺陷。**

---

## 参考

- 用户复核实测脚本：`fortune_master_tools/probe_qimen_verify.mjs`
- 修复后的 Edge Function：`supabase/functions/chart-qimen/index.ts`
- Deno 验证响应：完整 16 字段 / 9 宫 / yin dun / 6 局 / 值符天芮 / 值使死门 / 5 格局

---

**结案状态**：✅ 无 taibu-core bug，无需自实现，P0 #2 (4-6h) 已取消。