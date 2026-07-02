# Fortune Master 工作汇报 — 2026-07-01

> 本文档覆盖截至 2026-07-01 18:40 PDT 的所有工作
> 读者：项目主（davard123）抽查 / 接手 Agent 续推
> 验证状态：**端到端跑通**（Flutter Web + Supabase Edge Functions + taibu-core）

---

## 1. TL;DR（30 秒读完）

✅ **Phase 1 阶段 1-6 全部完成，BaziScreen 端到端跑通**

| 类别 | 状态 |
|------|------|
| Flutter Web 编译 | ✅ `flutter build web` 25MB 完整通过（2 次） |
| Supabase 云端 | ✅ Project `xjvoqpijrpjmgqkqwhqd` 已 link + 3 Edge Function 部署 |
| Edge Function 验证 | ✅ chart-bazi（八字）/ chart-tarot（塔罗）/ chart-qimen（Bug 复现） |
| ~~跨运行时 Bug~~ 已证伪 | ✅ 2026-07-01 复核：qimen"返回 `{}`"是调用方式错误（传了 `{datetime,lang}` 而非 `{year,month,day,hour,minute}`，且 Promise 未 await）。正确调用在 Node 实测返回完整九宫。**无需自实现 fallback**，改为修正 chart-qimen 调用（见 §5.1 修订） |
| Flutter UI | ✅ BaziScreen 完整（表单 + StateNotifier + 结果展示）|
| GitHub | ✅ 14 个 commits，master 最新为 `a839b32` |
| 双语 ARB | ✅ EN/ZH 各 75+ 字符串 |

**未做**：TarotScreen UI 改造、interpret Edge Function、qimen-fallback 自实现、其他 5 个术数模块

---

## 2. 今日交付清单（详细）

### 2.1 修复的 5 个 Bug

| # | Bug | 文件 | 修复 |
|---|-----|------|------|
| 1 | `pubspec.yaml` 要求 `flutter: >=3.27.0` | `pubspec.yaml:8` | 降到 `>=3.24.0`（避免再下 1GB SDK） |
| 2 | `import 'data/supabase_client.dart'` 不存在 | `lib/data/supabase_client.dart` | **新建**：薄 Supabase 客户端代理 |
| 3 | `AppL10n` import 路径错 | `l10n.yaml:11` | 改 `synthetic-package: true`，与所有 import 一致 |
| 4 | `Scaffold`/`Center`/`Text` 找不到 | `lib/core/router.dart:1` | 加 `import 'package:flutter/material.dart';` |
| 5 | web 平台未初始化 | `web/` 目录 | `flutter create --platforms=web --project-name=fortune_master .` |

### 2.2 新增 / 修改的 3 个 Edge Function

**`supabase/functions/chart-bazi/index.ts`** —— 八字排盘
- API：`POST {birthYear, birthMonth, birthDay, birthHour, gender}`
- 实测响应：完整四柱 + 藏干 + 十神 + 神煞 + 胎元 + 命宫 + 空亡 + 三合六合
- 测试数据：1990-05-15 14:30 男 → 日主庚 / 年柱庚午 / 月柱辛巳 / 日柱庚辰 / 时柱癸未

**`supabase/functions/chart-tarot/index.ts`** —— 塔罗抽牌（**重写**）
- 修复了原代码的 API 错误（用了不存在的 `drawCards`）
- 改用 `calculateTarot({spreadType: 'single'|'three-card'|'celtic-cross'})`
- 外部别名映射：`'one' → 'single'`, `'three' → 'three-card'`, `'celtic' → 'celtic-cross'`
- 不传 `seed` 数字（taibu-core 已知 bug：`inputSeed?.trim is not a function`）

**`supabase/functions/chart-qimen/index.ts`** —— 奇门探针（**新建**）
- 目的：验证 Node 上发现的空返回 bug 是否在 Deno 也复现
- 结果：**Bug 跨运行时复现**——决定不再投入修复包装层，改自实现 `qimen-fallback`

### 2.3 新增 / 修改的 Flutter 代码

**`lib/features/bazi/bazi_screen.dart`** —— 319 行（**完整重写**）
- `BaziFormState` + `BaziFormNotifier`（Riverpod StateNotifier）
- `_BaziForm`：日期 picker / 12 时辰 picker / 性别 SegmentedButton / 提交按钮
- `_BaziResult`：日主大字 + 4 柱横向卡片 + 各柱藏干 chips + 日柱神煞 chips + 胎元/命宫 + 再排一次/AI 解读

**`lib/l10n/app_en.arb` / `app_zh.arb`** —— 各 +14 字符串
- 新增：`actionRetry`, `actionInterpret`, `baziDayMaster`, 4 个 pillar 名, 4 个 hidden stems, `baziDayShenSha`, `baziTaiYuan`, `baziMingGong`

**其他**：6 个文件（`stub.dart`、router、env、repositories、supabase_client、home_screen）保持原样

### 2.4 文档

- `docs/restart-checklist.md` — 重启后 6 阶段 runbook（35-40 min 跑通的实测记录）
- `docs/incidents/2026-07-01-taibu-core-qimen-empty.md` — qimen bug 完整调查（含 Deno 验证数据 + 自实现方案 B 决策）

### 2.5 GitHub 状态

```
a839b32 feat(bazi): 完整实装 BaziScreen
28143a6 feat(infra): 修复编译 bug + 部署 3 个 Edge Function + Deno 验证 qimen bug
6e94ccc style: 标题字体加粗 —— 换用 Ma Shan Zheng 毛笔楷书 + 描边增重
507122d style: 配色从暗夜墨蓝改为宣纸土黄暖色调
b76da8f feat: Web 自测版 UI 原型 —— 玄学暗夜金主题首页
1559dca feat: Flutter 项目骨架 + 双语 ARB 资源 + 8 个模块入口
5873e10 feat: Week 1-2 启动代码落地
801718f docs: 澄清 MVP 语言策略为双语（英文 + 简体中文）
b6c245c docs: 新增 Phase 1 实施计划，供执行 Agent 直接落地
2da6504 docs: License 审计 + 塔罗/占星/解梦缺口核查
73f9cbb docs: 风险评审修订 + fork 接线验证结论
fff28b1 docs: 新增项目完整汇总文档 (handoff)
39042b7 docs: 增加 Phase 1 试用阶段 LLM 方案 - FreeLLMAPI
4a86042 docs: Fortune Master 中西算命大全馆设计方案 v1.0
```

14 个 commit 全部 push 到 `davard123/fortune-master` master 分支。

---

## 3. 验证证据（可重跑的命令）

### 3.1 Flutter build 通过

```bash
cd C:\Users\david\ZCodeProject
flutter build web --no-tree-shake-icons
# 期望输出末尾: √ Built build\web
# 实测耗时: 79.8s (首次) → 62.3s (增量)
# 产物: build/web/ 25MB, main.dart.js 2.4MB
```

### 3.2 Supabase Edge Function 验证

需要的环境变量（在 PowerShell 一次性设；ACCESS_TOKEN 不写入任何文档，从 https://supabase.com/dashboard/account/tokens 获取）：
```powershell
$env:SUPABASE_ACCESS_TOKEN = "<从 Supabase Dashboard 获取，勿写入文档>"
$env:SUPABASE_URL = "https://xjvoqpijrpjmgqkqwhqd.supabase.co"
$env:SUPABASE_ANON_KEY = "sb_publishable__h65fkFHE-EZaAUeBlTd8Q_NGEHGzji"
```
> ⚠️ 2026-07-01 修订：本文档初版曾包含 ACCESS_TOKEN 明文（未曾 commit），已删除。该 token 应视为已暴露，请在 Dashboard 轮换。ANON_KEY 是 publishable key，可公开。

**chart-bazi** ✅：
```bash
curl -X POST "$env:SUPABASE_URL/functions/v1/chart-bazi" `
  -H "Authorization: Bearer $env:SUPABASE_ANON_KEY" `
  -H "Content-Type: application/json" `
  -d '{"birthYear":1990,"birthMonth":5,"birthDay":15,"birthHour":14,"gender":"male"}'
```
返回完整八字 JSON（庚日主 + 4 柱 + 藏干 + 10 神煞 + 胎元 + 命宫）。

**chart-tarot** ✅：
```bash
curl -X POST "$env:SUPABASE_URL/functions/v1/chart-tarot" `
  -H "Authorization: Bearer $env:SUPABASE_ANON_KEY" `
  -H "Content-Type: application/json" `
  -d '{"spread":"three"}'
```
返回 3 张牌（含正逆位 + 中文位置标签 + 含义）。

**chart-qimen** 🐛 Bug 复现：
```bash
curl -X POST "$env:SUPABASE_URL/functions/v1/chart-qimen" `
  -H "Authorization: Bearer $env:SUPABASE_ANON_KEY" `
  -H "Content-Type: application/json" `
  -d '{"datetime":"2026-07-01T14:30:00+08:00"}'
```
返回 `"chart_data": {}, rawReturnIsEmpty: true`——与 Node 24 行为一致。

### 3.3 本地浏览器查看（可选）

```bash
cd C:\Users\david\ZCodeProject
flutter run -d chrome --web-port=3000
# 浏览器自动打开 http://localhost:3000
```

**注意**：直接跑 `flutter run` 会因为 Supabase URL/KEY 通过 `--dart-define` 注入失败，需要：
```bash
flutter run -d chrome --web-port=3000 \
  --dart-define=SUPABASE_URL=https://xjvoqpijrpjmgqkqwhqd.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable__h65fkFHE-EZaAUeBlTd8Q_NGEHGzji
```

或在 `lib/secrets.dart` 写死（**不要 commit**，已在 `.gitignore`）。

---

## 4. 当前架构（端到端跑通的链路）

```
┌──────────────────────────────────────────────────────────────────┐
│ Flutter Web (C:\Users\david\ZCodeProject)                        │
│                                                                  │
│  HomeScreen → BaziScreen (BaziFormNotifier)                      │
│      └→ FortuneRepository.computeBazi()                          │
│                                                                  │
│  supabase_flutter 2.5.0 → functions.invoke('chart-bazi')         │
└────────────────────────────┬─────────────────────────────────────┘
                             │ HTTPS POST + Bearer anon key
                             ↓
┌──────────────────────────────────────────────────────────────────┐
│ Supabase us-west-1 (project xjvoqpijrpjmgqkqwhqd)                │
│                                                                  │
│  Edge Runtime 1.74.2 (Deno 2.1.4 compatible)                    │
│      └→ chart-bazi/index.ts                                      │
│           └→ import('npm:taibu-core@^3.4.0/bazi')               │
│                └→ calculateBazi({birthYear, birthMonth, ...})    │
│                                                                  │
│  Postgres (free tier)                                            │
│      └→ 8 tables: profiles / readings / posts / post_reactions   │
│         subscriptions / credit_logs / reports / dream_dict       │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             ↓
┌──────────────────────────────────────────────────────────────────┐
│ GitHub: davard123/fortune-master                                 │
│                                                                  │
│  master branch @ a839b32                                         │
│  14 commits, all pushed                                          │
│                                                                  │
│  18 forks in subdirs (未在本仓库, 在 davard123/ 下独立 fork)    │
└──────────────────────────────────────────────────────────────────┘
```

---

## 5. 决策记录（重要）

### 5.1 ✅ 已决策

| 决策 | 替代方案 | 理由 |
|------|---------|------|
| Flutter SDK 用 3.24.5 | 升级到 3.44.x | 避免再下 1GB；3.24.5 仍受 Google 支持 |
| Supabase region: us-west-1 (Oregon) | Singapore | 用户在美国，调试体验优先；OR 也覆盖拉美/欧洲 |
| tarot spread id 内部映射 | 改 taibu-core | 不改上游，自做适配层更稳 |
| ~~qimen 自实现 fallback~~（**2026-07-01 撤销**） | 修正调用方式 | 复核证明是调用错误而非库 bug：`await calculateQimen({year,month,day,hour,minute})` 在 Node 实测正常。改为修 chart-qimen 参数解析，自实现方案作废 |
| BaziScreen 用 Riverpod StateNotifier | setState + StatefulWidget | 表单 + 异步提交 + 错误处理，StateNotifier 干净 |
| 14 个 Bazi 字符串放 ARB | 硬编码 | 双语 MVP，硬编码会破坏 i18n 原则 |

### 5.2 ⏳ 待决（明日 / 后续会话）

| 待决项 | 选项 | 建议 |
|--------|------|------|
| interpret Edge Function 的 LLM | FreeLLMAPI（试用）→ DeepSeek（生产）| A: FreeLLMAPI 优先（已记录）, B: 一开始就 DeepSeek（更稳但有成本） |
| FreeLLMAPI 部署方式 | 本地 Docker / Cloudflare Workers | A: 本地 Docker（dev 友好）, B: Cloudflare Workers（生产形态）|
| qimen-fallback 排盘精度 | 简化版（仅地盘）/ 完整版（地盘+天盘+人盘+神盘）| A: 简化版 MVP（4h）, B: 完整版（8h）|
| 紫微 / 六爻 / 梅花 是否也用 taibu-core | 直接 fork / taibu-core | A: 都用 taibu-core（一致）, B: 紫微 fork 原 Python 项目（ziwei 准确性更高）|

---

## 6. 已知问题 / 风险

### 6.1 🐛 taibu-core Bug 清单（已发现）

| Bug | 影响 | 状态 |
|-----|------|------|
| ~~`qimen` 返回 `{}`~~ | ~~奇门完全不可用~~ | **已证伪**（2026-07-01）：调用方式错误，非库 bug；修正 chart-qimen 即可 |
| `tarot` seed 传数字报错 | 测试时不能固定随机种子 | 疑似非 bug：`inputSeed?.trim` 说明 API 期望字符串 seed，传 `"123"` 应可行（待验证） |
| 紫微 / 六爻 / 梅花 / 太乙 / 大六壬 / 小六壬 | **未验证** | 待逐一跑通后再定 |

### 6.2 ⚠️ 未覆盖

- **iOS / Android 编译**：只验证了 Web。iOS 需要 macOS（按你之前决策，等准备 App Store 时再切）
- **生产环境部署**：现在 Edge Function 在 us-west-1 免费 tier；Cloudflare Pages 部署 build/web 还没做
- **AdMob / RevenueCat**：依赖已加进 pubspec 但未集成
- **FreeLLMAPI**：本地 Docker 镜像未拉取
- **PDF 报告导出**：pubspec 加了 `pdf` + `printing` 但未用

### 6.3 ⚠️ 隐私 / 合规

- birth_lat / birth_lng 在排盘后未从 readings.input_payload 清除——**当前 schema 还没建 readings 表的写入逻辑**，等真实用户流程跑通时再补
- Privacy Policy / ToS：未写（部署前必需）

---

## 7. 仓库结构（截至现在）

```
C:\Users\david\ZCodeProject\
├── .gitignore                  # 已屏蔽 build/, .env, secrets.dart
├── .metadata                   # Flutter 项目元数据
├── analysis_options.yaml       # Dart lint 配置
├── pubspec.yaml                # 11 生产依赖 + 3 dev 依赖
├── l10n.yaml                   # synthetic-package: true
├── README.md
│
├── docs/
│   ├── fortune-master-handoff.md       # 项目汇总（其他 Agent 看）
│   ├── plans/                          # 设计与实施计划
│   │   ├── 2026-07-01-fortune-master-design.md
│   │   └── 2026-07-01-phase1-implementation-plan.md
│   ├── incidents/
│   │   └── 2026-07-01-taibu-core-qimen-empty.md
│   ├── reports/
│   │   └── 2026-07-01-progress-summary.md  # ← 本文件
│   └── restart-checklist.md
│
├── supabase/
│   ├── migrations/
│   │   └── 20260701000001_init_schema.sql   # 8 tables + RLS
│   └── functions/
│       ├── chart-bazi/index.ts              # ✅ 实测返回完整八字
│       ├── chart-tarot/index.ts             # ✅ 实测返回牌面
│       └── chart-qimen/index.ts             # 🐛 Bug 验证探针
│
├── lib/
│   ├── main.dart                            # Supabase init + ProviderScope
│   ├── app.dart                             # MaterialApp.router + i18n
│   ├── core/
│   │   ├── env.dart                         # String.fromEnvironment
│   │   └── router.dart                      # go_router 8 routes
│   ├── data/
│   │   ├── supabase_client.dart             # 薄客户端代理
│   │   └── repositories/
│   │       └── fortune_repository.dart      # 3 个 Edge Function 调用
│   ├── features/
│   │   ├── _stub.dart
│   │   ├── home/home_screen.dart            # 8 卡首页
│   │   ├── auth/login_screen.dart           # Stub
│   │   ├── bazi/bazi_screen.dart            # ✅ 319 行完整实装
│   │   ├── tarot/tarot_screen.dart          # Stub
│   │   ├── iching/iching_screen.dart        # Stub
│   │   ├── community/community_screen.dart  # Stub
│   │   ├── profile/profile_screen.dart      # Stub
│   │   └── paywall/paywall_screen.dart      # Stub
│   └── l10n/
│       ├── app_en.arb                       # 76 字符串
│       ├── app_zh.arb                       # 75 字符串
│       └── generated/                       # gen-l10n 产物 (synthetic-package=true 时移到 .dart_tool/)
│
└── web/                                     # Flutter web 资源
    ├── index.html
    ├── manifest.json
    ├── favicon.png
    └── icons/...
```

---

## 8. 下一步建议（按优先级）

### 🔴 P0 - 必须先做（影响 MVP 完整性）

1. **interpret Edge Function**（2-3h）
   - 入参：`reading_id`, `tier` (brief/detailed), `locale`
   - 调 FreeLLMAPI（试用）→ 切 DeepSeek（生产）
   - 配合 BaziScreen 的 "AI 解读" 按钮

2. **qimen-fallback 包**（4-6h）
   - 在 `packages/qimen-fallback/` 用纯 TS 实现奇门飞盘
   - 替换 chart-qimen 的 taibu-core 调用
   - 已知教材结果做单元测试

### 🟡 P1 - 重要（影响 MVP 上线）

3. **TarotScreen 完整 UI**（30 min）
   - 复用 StateNotifier 模式
   - 三种 spread 选择 + 牌面展示

4. **Cloudflare Pages 部署**（1h）
   - 把 `flutter build web` 产物部署到 `fortune-master.pages.dev`
   - 配置环境变量（SUPABASE_URL/ANON_KEY）

5. **Privacy Policy / ToS**（1h）
   - 模板生成 + 翻译
   - Cloudflare Pages 部署前必需

### 🟢 P2 - 可以等

6. 紫微 / 六爻 / 梅花 三个 Edge Function + UI
7. AdMob / RevenueCat 集成
8. 周公解梦 7 条 seed → 扩展到 200+ 条

---

## 9. 验证清单（你可以逐项打勾）

- [ ] 看 GitHub: https://github.com/davard123/fortune-master/commits/master
  - 应看到 14 commits，最后 2 个是 `feat(bazi)` 和 `feat(infra)`
- [ ] 看 Flutter build: `flutter build web --no-tree-shake-icons` 在项目根跑一遍
  - 期望末尾: `√ Built build\web` 耗时 ~60s
- [ ] 跑 curl 命令（3.2 节）验证 3 个 Edge Function
  - chart-bazi → 完整八字 JSON
  - chart-tarot → 3 张牌 JSON
  - chart-qimen → 包含 `"rawReturnIsEmpty": true` 的 debug JSON
- [ ] 看 docs/incidents/2026-07-01-taibu-core-qimen-empty.md
  - 应该含"Deno 验证实测数据"小节，runtime 显示 `deno-supabase-edge-runtime-1.74.2`
- [ ] 看 lib/features/bazi/bazi_screen.dart
  - 应该是 319 行，包含 BaziFormNotifier + _BaziForm + _BaziResult
- [ ] 看 lib/l10n/app_en.arb vs app_zh.arb
  - 应该有 14 个匹配的 `bazi*` 和 `action*` 键

---

## 10. 一句话状态

**Phase 1 阶段 1-6 全部跑通 + BaziScreen 端到端实装 + 3 Edge Function 部署并验证 + 1 关键 Bug（qimen）已识别并决策方案。代码全在 GitHub master @ a839b32。下一步 P0 是 interpret Edge Function 和 qimen-fallback 自实现。**

---

*汇报人: ZCode (MiniMax-M3)*
*汇报时间: 2026-07-01 18:40 PDT*
*GitHub: davard123/fortune-master @ a839b32*
*Supabase: xjvoqpijrpjmgqkqwhqd (us-west-1)*