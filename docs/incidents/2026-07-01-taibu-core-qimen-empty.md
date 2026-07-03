# Incident: taibu-core 奇门排盘 — 两轮诊断，最终自实现替代

**日期**：2026-07-01 ~ 2026-07-02
**严重度**：🟡 最终结论：taibu-core/qimen 在 Supabase Edge Runtime 下**结果不可信**（非崩溃性 bug，是静默算错），已改用自实现引擎替代
**状态**：✅ **已修复**（`supabase/functions/_shared/qimen-native.ts`，2026-07-02 部署验证）

---

## 时间线总览（两轮诊断，缺一不可）

1. **第一轮（2026-07-01）**：诊断出"返回空对象"是调用姿势错误（忘 await + 参数形状错），**不是** taibu-core bug。这个结论**依然成立**，见下方"第一轮：调用姿势问题"。
2. **第二轮（2026-07-02）**：调用姿势修好后，结果不再是空对象，但**逐宫交叉验证发现日柱/时柱天干算错**——这是 taibu-core 库本身的架构限制（内部依赖真实修改 `process.env.TZ`，Deno Edge Runtime 禁止运行时改环境变量），不是参数问题，无法在调用方打补丁修复。最终改为自实现拆补法排盘引擎，不再依赖 taibu-core/qimen。见下方"第二轮：时区精度问题"。

---

## 第一轮：调用姿势问题（2026-07-01，结论依然成立）

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

## 第二轮：时区精度问题（2026-07-02，推翻"无需自实现"结论）

### 发现过程

调用姿势修好、部署上线后，用同一时刻（`2026-07-01 14:30` 上海时间）交叉验证：

| 计算方式 | 日柱 | 时柱 |
|---|---|---|
| 部署的 chart-qimen（taibu-core, 传 `{year:2026,month:7,day:1,hour:14,minute:30}`, 不传 timezone） | `丁丑` | `丁未` |
| `lunar-javascript` 直接计算同一时刻（`Solar.fromYmdHms(2026,7,1,14,30,0).getLunar()`） | `丙子` | `乙未` |

**两者不一致**。`lunar-javascript` 是纯历法计算（不依赖系统时区），也是八字模块（`chart-bazi`）在用的同一套库，结果可信。奇门返回的日柱天干是错的。

### 根因（taibu-core 源码证实，非猜测）

`taibu-core/dist/domains/qimen/calculate.js` 的核心函数注释：

```
// 注意：taobi 库依赖 process.env.TZ 来正确解析 Date 对象。
const previousTimeZone = process.env.TZ;
process.env.TZ = timezone;
try {
    const date = new Date(year, month - 1, day, hour, minute);
    t = new TheArtOfBecomingInvisible(date, ...);
```

`taibu-core` 自己的 `shared/timezone-utils.ts` 里有一个专门为"不能改系统时区的沙箱环境"设计的安全工具函数 `zonedWallClockToSystemDate`（纯 `Intl` 计算，不需要改 `process.env`），但 qimen 模块的注释明确写着：

> "taobi 库内部使用 Date 的 UTC 时间戳，zonedWallClockToSystemDate 无法替代。"

也就是说：taobi（奇门核心算法库）不是读 `Date` 的本地时间读数（可以伪造），而是直接读 `.getTime()`（绝对 UTC 时间戳）驱动内部的 Julian Day / 干支计算，而这个时间戳只能靠**真正修改系统时区、让 JS 引擎原生构造出正确的 `new Date(...)`** 才能算对。Supabase Edge Runtime 里 `process.env.TZ = ...` 直接抛 `The operation is not supported`，所以这个前提在 Edge Function 里永远不成立。

**尝试过的绕过方案，均失败**：
- 吞掉 env 写入错误（no-op），强制传 `timezone:'UTC'` + 手动做 UTC 偏移换算 → 语义错误（把"上海 14:30"当成"UTC 14:30"直接算，等于时间点错了 8 小时）
- `Date` 子类替换全局 `Date`，伪造本地 getter → minified bundle 未采用该引用，未生效
- 只 patch `Date.prototype.getTimezoneOffset()` 等方法，不碰构造函数 → 构造函数是 V8 原生实现，读取真实系统时区，无法从 JS 层拦截，导致 getter 和 epoch 不一致，结果更乱

**结论：这是 taibu-core 库的架构限制，在当前 Supabase Edge Runtime（禁止运行时改环境变量）下无法在调用方修复。**

### 最终修复：自实现拆补法排盘引擎

`supabase/functions/_shared/qimen-native.ts`（2026-07-02 新增，~330 行）：

- 四柱：直接用 `lunar-javascript`（和八字模块同一套库，纯历法计算，不依赖系统时区）
- 局数/阴阳遁判定：拆补法，二十四节气对照表，交叉核实了两个独立中文资料来源
- 地盘三奇六仪排布：**已用一个完整实例逐宫验证通过**（癸卯年戊午月己酉日戊辰时 / 农历癸卯年五月初三 8 时 / 公历 2023-06-20 08:00，芒种，阳遁六局 → 六宫起戊，戊己庚辛壬癸丁丙乙顺排，9 个宫全部吻合）
- 值符值使定位、天盘九星/人盘八门的旋转方向：**中等置信度**——中文资料对旋转方向存在流派分歧（转盘法/飞盘法），本实现统一按"阳顺阴逆"处理，但没有找到可逐宫核对的权威实例。**上线前建议找一个可信的奇门排盘工具/教材做逐宫比对**，返回结果里的 `_meta.confidence` 字段已如实标注这一点。

实测（2026-07-02，Deno 部署）：`2026-07-01 14:30` 上海时间 → 日柱 `丙子`，时柱 `乙未`，与 `lunar-javascript` 权威基准一致。

---

## 参考

- 用户复核实测脚本：`fortune_master_tools/probe_qimen_verify.mjs`
- 第一轮修复后的 Edge Function（调用姿势）：`supabase/functions/chart-qimen/index.ts`
- 第二轮最终引擎（自实现，替代 taibu-core/qimen）：`supabase/functions/_shared/qimen-native.ts`
- 二十四节气局数表来源：知乎 p/648135351 与另一独立来源交叉验证；地盘排列规则+完整实例：知乎 p/644619189（通过搜索摘要获取）

---

**最终状态**：✅ 已修复。奇门遁甲不再依赖 taibu-core，四柱/局数/地盘高置信度，值符值使与星门旋转方向中等置信度（待人工核对）。