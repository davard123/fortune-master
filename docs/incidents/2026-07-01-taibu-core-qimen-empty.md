# Incident: taibu-core 奇门排盘在 Node 环境返回空对象

**日期**：2026-07-01
**发现人**：davard123（通过 Claude 自动化验证）
**严重度**：🔴 高（核心术数之一完全不可用）

## 现象

`taibu-core`（v3.4.0+，MIT，`npm install taibu-core`）的 `calculateQimen()` 在 Node v24.14.0 下，传入合法参数（`year/month/day/hour/minute`）返回 **空对象 `{}`**，而非预期的奇门飞盘结果。

## 已排除的可能原因

- ✅ taibu-core 安装成功（`npm install taibu-core` 无错）
- ✅ 8 个域函数均可 `require`（`bazi/qimen/astrology/ziwei/liuyao/...`）
- ✅ `calculateBazi()` 正常返回完整四柱
- ✅ `calculateAstrology()` 正常返回 natal chart
- ❌ `calculateQimen()` 返回 `{}`

## 推测根因（待验证）

`taibu-core/qimen` 内部通过**临时修改**全局变量 `process.env.TZ` 处理时区转换。Node 下：

1. **可能 1**：`process.env.TZ` 修改后，`Date()` 对象已经缓存了旧的时区 offset，无法再更新（V8 Date 内部有缓存）
2. **可能 2**：奇门依赖 `Intl.DateTimeFormat` 计算，时间在格式化前就要定型
3. **可能 3**：奇门内部依赖 `lunar-javascript` 的某段时区敏感代码

具体根因未在源码层面确认。

## 已知 Workaround 候选方案

### 方案 A：包装层做时区偏移（推荐）
```ts
function calculateQimenSafe(input: { year: number; month: number; day: number; hour: number; minute: number; tz: string }) {
  // 1. 把目标时区的本地时间转 UTC
  // 2. 用 UTC 时间调用 taibu-core.calculateQimen
  // 3. 因为 taibu-core 内部 getSolarDate 期望的是"未做时区转换的本地时间数字",
  //    所以传 UTC 数字其实是错的, 还要继续探索
  throw new Error('TBD');
}
```

### 方案 B：换实现
- 改用 fork 的 `Brhiza/mingyu`（其 qimen 实现是否同样依赖 tz?)
- 用纯 JS 重写奇门飞盘（数学工作量约 200 行，已知算法公开）

### 方案 C：在 Deno 上验证
- 部署到 Supabase Edge Function 后再看行为
- Deno 下 `process.env.TZ` 对 Date 的影响可能和 Node 不一样

## 下一步

1. **Week 3 必做**：在 Supabase Edge Function（Deno 运行时）实测一次 `calculateQimen` 的行为
2. **如果 Deno 也失败**：评估方案 A 与方案 B 的工作量；建议方案 B 抽出独立模块 `packages/qimen-fallback/`
3. **defer**：本周不做进一步调查，等 Deno 验证后再定方案（避免 Node + Deno 都要修）

## 参考

- 验证脚本：`~/fortune_master_tools/verify-taibu.js`
- 测试环境：Windows 11, Node 24.14.0, taibu-core (npm latest)
- 测试参数：2026-07-01 12:00, Asia/Shanghai
- 输出：`{}` (空对象)

## 影响范围

| 术数 | Phase 1 影响 |
|------|---------------|
| 八字 | ✅ OK |
| 紫微 | ⚠️ 待验证（疑似同套时区机制）|
| 奇门 | ❌ Broken in Node |
| 西占星 | ✅ OK |
| 塔罗 | ⚠️ 待验证（可能不依赖时区）|
| 六爻 / 梅花 / 太乙 / 大六壬 / 小六壬 | ⚠️ 待逐一验证 |
| 周公解梦 | ✅ 自建，无依赖 |
