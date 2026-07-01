# Fortune Master · 中西算命大全馆 · 完整设计方案

> **品牌中文名**：中西算命大全
> **海外品牌名**：Fortune Master（App Store 主标题）
> **方案版本**：v1.0 · 2026-07-01
> **作者**：davard123
> **状态**：待评审

---

## 0. 一句话定位

> 一个面向海外华人 / 英语圈的「一站式玄学 App 大全馆」，把 8~15 种中西算命术数做成 Flutter 跨端产品（Web + iOS + Android 同源），先 Web 验证模式、再拆分成独立 App 矩阵上架。免费排盘、广告解锁轻度解读、订阅/付费解锁深度报告 + PDF 导出。

---

## 1. 决策一览（已与用户确认）

| 维度 | 决策 |
|---|---|
| 发布市场 | 海外 App Store（美 / 港 / 日）+ 全球 Web |
| Apple 资质 | 已有付费个人/公司账号 |
| 运作模式 | 免费 + 广告解锁 + 订阅/付费解锁深度报告 |
| 术数范围 | 首发 Medium 8 种 → 长期 Full 15+ 种 |
| UI 技术栈 | **Flutter 跨端**（Web + iOS + Android + macOS 同一份代码） |
| 部署 | Web 用 **Cloudflare Pages + Workers**，App 走 Apple/Google 商店 |
| 后端 | **Supabase**（Postgres + Auth + Edge Functions + Storage） |
| 算法集成 | fork 项目**重写为 TS → Supabase Edge Functions**（Fortune Engine API） |
| LLM 主力 | **Phase 0-1 试用**：[FreeLLMAPI](https://github.com/tashfeenahmed/freellmapi)（自托管代理 + 16 个免费 LLM，月 ~17B tokens 免费）<br>**Phase 2+ 正式**：[DeepSeek](https://platform.deepseek.com)（中文命理解读最优解，¥1/M tokens 输入） |
| MVP 语言 | 英文 + 简体中文 |
| 社区功能 | 包含：解读分享墙 + 评论 + 点赞 |
| 合规策略 | MVP：标准化免责声明 + Privacy Policy + ToS |
| 品牌 | 中文"中西算命大全" / 海外英文"Fortune Master" |
| GitHub 账号 | davard123 |

---

## 2. 已 Fork 的开源仓库清单

> 每个术数挑 2 个高分项目，便于交叉验证算法。所有 fork 均在 `davard123` 账号下。License 列已于 2026-07-01 通过 GitHub API 逐一核实（见 §2.7），**不再是未验证假设**。

### 2.1 八字（命理核心）
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| china-testing/bazi | 1,386 | https://github.com/davard123/bazi | ⚠️ 无 LICENSE 文件、README 未声明 |
| axbug/8Char-Uni-App | 277 | https://github.com/davard123/8Char-Uni-App | GPL-3.0（copyleft，谨慎使用） |
| hkargc/paipan | 164 | https://github.com/davard123/paipan | WTFPL（宽松） |
| masterai-top/Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code | 53 | https://github.com/davard123/Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code | ⛔ 自定义"MIT with Commercial Restrictions"，**明确禁止商用**，需另购商业授权 |

### 2.2 紫微斗数
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| hhszzzz/taibu | 291 | https://github.com/davard123/taibu | 仓库根目录 **AGPL-3.0-only**；仅 `packages/core`（即 npm 包 `taibu-core`）单独声明 **MIT** |
| Brhiza/mingyu | 172 | https://github.com/davard123/mingyu | ⚠️ 无 LICENSE 文件、README 未声明 |

### 2.3 周易 / 易经
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| kentang2017/ichingshifa | 263 | https://github.com/davard123/ichingshifa | MIT ✅ |
| chengjun/iching | 125 | https://github.com/davard123/iching | MIT ✅ |
| xinliulab/Future-Telling-By-I-Ching | 102 | https://github.com/davard123/Future-Telling-By-I-Ching | ⚠️ 无 LICENSE 文件、README 未声明 |

### 2.4 塔罗
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| ekelen/tarot-api | 391 | https://github.com/davard123/tarot-api | ⚠️ 无 LICENSE 文件、README 未声明 |
| dreamhunter2333/chatgpt-tarot-divination | 823 | https://github.com/davard123/chatgpt-tarot-divination | MIT（仅 README 声明，无独立 LICENSE 文件，效力弱于正式 LICENSE） |
| uxiaohan/Tarot-Web | 106 | https://github.com/davard123/Tarot-Web | ⚠️ 无 LICENSE 文件、README 未声明 |

### 2.5 奇门遁甲 / 六壬 / 太乙神数
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| hhszzzz/taibu（已含） | 291 | （见上） | 见 2.2 |
| Brhiza/mingyu（已含） | 172 | （见上） | 见 2.2 |
| H1d3rOne/xuan-deduct | 23 | https://github.com/davard123/xuan-deduct | MIT ✅ |

### 2.6 其他
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| NodleCode/Nodle-I-Ching | 276 | https://github.com/davard123/Nodle-I-Ching | GPL-3.0（copyleft，谨慎使用） |
| gclinux/etaoism | 82 | https://github.com/davard123/etaoism | ⚠️ 无 LICENSE 文件、README 未声明 |

### 2.7 License 核查结论（2026-07-01，GitHub API 实测，非假设）

原方案多处断言"全部 MIT/Apache-2.0，重写无版权风险"，**实测结果并非如此**：15 个仓库里，只有 5 个是明确的宽松许可（MIT ×4、WTFPL ×1），其余 10 个要么是 copyleft（GPL-3.0 ×2）、要么明确禁止商用（masterai-top 的自定义许可）、要么**完全没有声明许可**（7 个仓库只有 README，无 LICENSE 文件，法律上默认"保留所有权利"，未经许可不能重用/再分发）。

**对本方案的实际影响很小**，因为 §5.2 已确认核心算法改用 `taibu-core`（npm 包，MIT，独立于 taibu 仓库根目录的 AGPL-3.0）——**不要从 `taibu` 仓库根目录（`src/`、`supabase/`、`public/` 等）复制任何代码，只用发布到 npm 的 `taibu-core` 包**，这样就不会触碰到 AGPL 条款。其余 13 个 fork 现在的定位是"备用/交叉验证参考"，不是必须移植的对象，所以：
- 无 License 声明的 7 个仓库（china-testing/bazi、Brhiza/mingyu、xinliulab/Future-Telling-By-I-Ching、ekelen/tarot-api、uxiaohan/Tarot-Web、gclinux/etaoism，另加 dreamhunter2333 效力较弱的 README 声明）——**不要直接复制代码或数据**，如果只是参考实现思路（不复制原文件）问题不大，但不能像 §5.2 原计划那样"重写抽核心算法"式地大段复用。
- `masterai-top/...`——**明确写死禁止商用**，之前方案把它列为八字/紫微/奇门/遁甲的参考来源之一，需要从"可复用清单"里剔除，只能当纯理论参考读。
- GPL-3.0 的两个（8Char-Uni-App、Nodle-I-Ching）——copyleft，如果不打算开源自己的 Edge Function 代码，不要直接复制它们的代码进正式产品。

---

## 3. 整体技术架构

```
┌──────────────────────────────────────────────────────────────────┐
│                      客户端层 (Flutter 全端)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │  Web (CF Pages)│  │  iOS App     │  │  Android App │            │
│  │  Flutter Web  │  │  App Store   │  │  Play Store  │            │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘            │
│         └─────────────────┼─────────────────┘                    │
│                           │ HTTPS + JWT                           │
└───────────────────────────┼──────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                      Supabase BaaS 层                              │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐    │
│  │  Auth (邮箱/Apple/Google) │  │  Postgres (用户/解读/评论) │  │  Storage (PDF/图片)  │    │
│  └────────────────┘  └────────────────┘  └──────────────────┘    │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │       Fortune Engine API (Supabase Edge Functions)        │    │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │    │
│  │  │ 八字排盘│ │ 紫微斗数│ │  卦象  │ │ 塔罗抽牌│ │ 占星星图│ │    │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ │    │
│  └──────────────────────────────────────────────────────────┘    │
└───────────────────────────┬──────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                      外部 LLM + 第三方服务                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐       │
│  │  DeepSeek API │  │  AdMob (广告) │  │ RevenueCat (IAP)  │       │
│  └──────────────┘  └──────────────┘  └──────────────────┘       │
└──────────────────────────────────────────────────────────────────┘
```

### 3.1 关键架构原则

1. **算法即服务**：所有排盘算法在 Edge Functions 中实现，对客户端是纯 API。客户端永远拿不到原始 fork 代码（保护版权 + 避免客户端被篡改）。
2. **LLM 永远在服务端**：客户端永远不直接调用 DeepSeek（API Key 不能暴露）。
3. **数据库是事实来源**：用户的解读历史、评论、点赞都在 Postgres，可长期留存做数据资产。
4. **订阅/支付走平台合规通道**：iOS 必走 StoreKit（IAP），Web 走 Stripe。广告统一 AdMob（Flutter 插件）。

---

## 4. 数据模型（Supabase Postgres）

> **出生信息生命周期原则**：`birth_lat/birth_lng`（精确经纬度）是高敏感 PII，即使 `profiles.birth_*` 字段为用户主动保存（用于跨设备同步），`readings.input_payload` 里的原始出生信息也应在排盘计算完成后尽快脱敏——只保留排盘结果 `chart_data` 长期存储，`input_payload` 中的精确经纬度不做永久明文留存（可只保留到城市/时区级精度，或计算后清空）。Privacy Policy 需明确写出"生辰信息仅用于当次计算，服务端不永久存储原始经纬度明文"。

```sql
-- 用户表（auth.users 由 Supabase Auth 管理）
profiles (
  id            uuid PK REFERENCES auth.users,
  display_name  text,
  locale        text DEFAULT 'en',         -- 'en' | 'zh-CN' | 'zh-TW' | ...
  birth_date    date,                       -- 缓存主用生日
  birth_time    time,
  birth_tz      text,
  birth_lat     numeric,
  birth_lng     numeric,
  gender        text,
  free_credits  int DEFAULT 5,              -- 免费额度
  is_premium    bool DEFAULT false,
  created_at    timestamptz DEFAULT now()
)

-- 排盘记录
readings (
  id              uuid PK,
  user_id         uuid REFERENCES profiles,
  system          text,                      -- 'bazi' | 'ziwei' | 'iching' | 'tarot' | ...
  input_payload   jsonb,                     -- 用户输入（生日/卦题/问题）
  chart_data      jsonb,                     -- 排盘结果（八字四柱/卦象/牌阵）
  tier            text,                      -- 'free' | 'ad_unlocked' | 'premium'
  llm_interp     text,                      -- DeepSeek 生成的解读
  llm_model       text,
  created_at      timestamptz DEFAULT now()
)

-- 解读分享到社区
posts (
  id              uuid PK,
  user_id         uuid REFERENCES profiles,
  reading_id      uuid REFERENCES readings,
  title           text,
  body            text,
  image_url       text,                      -- 分享卡图片
  tags            text[],
  is_anonymous    bool DEFAULT false,
  created_at      timestamptz DEFAULT now()
)

-- 评论 / 点赞
post_reactions (
  post_id         uuid REFERENCES posts,
  user_id         uuid REFERENCES profiles,
  kind            text,                      -- 'like' | 'comment'
  body            text,                      -- 评论内容
  created_at      timestamptz DEFAULT now(),
  PRIMARY KEY (post_id, user_id, kind)
)

-- 订阅状态（RevenueCat webhook 同步）
subscriptions (
  id              uuid PK,
  user_id         uuid REFERENCES profiles,
  plan            text,                      -- 'monthly' | 'yearly'
  expires_at      timestamptz,
  rc_original     jsonb,                     -- RevenueCat 原始 payload
  created_at      timestamptz DEFAULT now()
)

-- 解读配额使用
credit_logs (
  id              uuid PK,
  user_id         uuid REFERENCES profiles,
  delta           int,                       -- 正负
  reason          text,                      -- 'free_signup' | 'ad_watched' | 'premium' | 'reading_used'
  reading_id      uuid REFERENCES readings,
  created_at      timestamptz DEFAULT now()
)
```

---

## 5. Fortune Engine API（Supabase Edge Functions）

### 5.1 端点设计

```
POST /v1/chart/bazi           { birth: {...} }              → 八字排盘
POST /v1/chart/ziwei          { birth: {...} }              → 紫微排盘
POST /v1/chart/iching         { method: 'coins'|'yarrow' }  → 摇卦
POST /v1/chart/tarot          { spread: 'three'|'celtic', deck } → 塔罗抽牌
POST /v1/chart/qimen          { datetime, ju }              → 奇门排盘
POST /v1/chart/liuren         { datetime, method }         → 大六壬
POST /v1/chart/horoscope      { birth, house }             → 西占星盘
POST /v1/interpret            { reading_id, level: 'brief'|'detailed'|'pdf' }
  ↓ 内部调用 DeepSeek，返回自然语言解读

GET  /v1/share/:reading_id    → 生成分享卡 SVG
POST /v1/export/pdf           { reading_id }                → 生成 PDF 报告
```

### 5.2 算法实现策略（已实测验证，2026-07-01）

**核心结论：不需要对 14 个 fork 逐一重写。`hhszzzz/taibu` 已经把核心算法拆成一个独立发布的 npm 包 `taibu-core`（MIT License，当前 v3.4.0，`npm install taibu-core` 即可），domains 覆盖：**

```
almanac, astrology, bazi, bazi-dayun, bazi-pillars-resolve,
daliuren, liuyao, meihua, qimen, taiyi,
xiaoliuren, ziwei, ziwei-flying-star, ziwei-horoscope, tarot
```

**这基本覆盖了 Medium-8 里除周公解梦（本来就是自建）外的全部术数。** 实测（本地 Node 环境，`npm install taibu-core` 后直接 `import 'taibu-core/qimen'` / `'taibu-core/bazi'`）：

- `calculateQimen({ year, month, day, hour, minute })`——**8 个术数里复杂度最高（⭐⭐⭐⭐⭐）的奇门遁甲**，零改动直接调用成功，返回完整九宫飞盘（值符值使、九星八门八神、纳音空亡等）。
- `calculateBazi({ birthYear, birthMonth, birthDay, birthHour, gender })`——八字直接调用成功，返回完整四柱（十神/藏干/纳音/神煞/空亡）。
- `ziwei / liuyao / meihua / tarot / taiyi / daliuren / astrology / xiaoliuren` 的 `calculate*` 函数均可正常 `import`（未逐一跑通输出，但导入和类型定义均正常）。

**因此原计划里"重写 `china-testing/bazi`（Python）、`kentang2017/ichingshifa`（Python）"这两项工作可以直接砍掉**：
- `china-testing/bazi` 依赖 `lunar_python`（PyPI 包）和 `sxtwl`（原生天文历库），无法在 Deno 里跑；但 `taibu-core` 用的是 `lunar_python` 的 JS 姊妹库 `lunar-javascript`（同一作者 6tail 维护），八字实现已经比这个 fork 更完整，直接弃用该 fork。
- `kentang2017/ichingshifa` 是 Streamlit 全栈 App，算法耦合在 UI 代码里，还依赖 numpy/ephem，核心卦象数据库是一个二进制 pickle 文件（无法被 JS 直接读取）。`taibu-core` 已自带 `liuyao`（六爻）和 `meihua`（梅花易数）两个模块——如果这两种起卦法能覆盖产品需求，同样可以跳过这个 fork；只有明确要做「大衍之数/蓍草占卜」这个特定流派时，才需要单独把 ichingshifa 的 `data.pkl` 转成 JSON 后移植。

**唯一需要在真实环境里补测的风险点**：`taibu-core` 的奇门算法内部通过临时修改全局变量 `process.env.TZ` 来处理时区转换（配合内置互斥锁防止并发请求互相干扰），这是 Node 环境下常见但脆弱的写法。本地用 **Node** 验证是通的，但 Supabase Edge Functions 跑的是 **Deno** 运行时，`process.env.TZ` 对 `Date` 计算是否同样生效，需要在真正部署到 Supabase 项目（或至少 `deno run`）后再测一次，不能假设 Node 和 Deno 行为完全一致。

**修订后的复用策略**：Week 3-7 的排盘 Edge Function 开发，优先直接 `npm install taibu-core` 后按 domain 逐个接线（真正是"改 UI + 接数据"量级的工作）；`tarot-api`、`chatgpt-tarot-divination`、`Nodle-I-Ching` 等其余 fork 降级为"备用/交叉验证参考"，不再是必须移植的对象；`china-testing/bazi`、`kentang2017/ichingshifa` 直接标记为弃用（除非后续明确需要蓍草占卜这个细分流派）。

### 5.2.1 西占星验证 + 两个仍未覆盖的素材缺口（2026-07-01 实测）

- **西占星**：`taibu-core/astrology` 的 `calculateAstrology({ birthYear, birthMonth, birthDay, birthHour, birthMinute, longitude, latitude })` 实测调用成功，返回本命盘（十大行星、Placidus 宫位制、五种相位）+ 行运盘 + 相位列表，质量足够支撑 Tier 1/2 解读——**原计划里 `g-battaglia/Astrologer-API` 这个 fork（尚未完成 fork）大概率不再需要**，可以从 Week 1 收尾任务里的"待补 fork"清单中移除。
- **塔罗牌面素材缺口**：`ekelen/tarot-api` 只有卡牌含义的 JSON 数据（`card_data.json`），`uxiaohan/Tarot-Web` 没有牌面图片资源——**两个 fork 都不提供 78 张牌的图片素材**，`taibu-core/tarot` 大概率也只是抽牌逻辑。韦特-史密斯（Rider-Waite-Smith，1909）原版画作在美国已进入公有领域，可以直接用 Wikimedia Commons / sacred-texts.com 上的公版扫描图作为素材来源，不依赖任何一个 fork。
- **周公解梦内容缺口**：15 个 fork 里没有一个覆盖周公解梦原文数据，与原方案"自建"的定位一致——需要单独寻找《周公解梦》公版文本数据源（原文成书年代久远、早已进入公有领域，但要注意甄别市面上"整理版"是否有现代整理者的版权）。

### 5.3 解读 Prompt 设计

```typescript
// Brief 解读 (轻度 LLM，免费/广告解锁)
const briefPrompt = `
你是 Fortune Master 的资深命理师。基于以下${system}排盘数据：
${JSON.stringify(chart)}

请用${locale}给出一段 200 字以内的精炼解读，覆盖：
- 性格核心特征（2-3 点）
- 当前运势核心提示（1 点）
- 一句可执行的建议

语气温和、神秘但不神棍，**明确不构成决策建议**。
`;

// Detailed 解读 (重度 LLM，订阅/付费)
const detailedPrompt = `
...（更长、更结构化的解读模板，含流年/流月/财运/事业/感情/健康六大维度）
`;

// PDF 报告 (最重度，包含图表 + 完整解读 + 行动建议)
const pdfPrompt = `
...（生成结构化 JSON，前端模板渲染为 PDF）
`;
```

---

## 6. 客户端架构（Flutter）

### 6.1 项目结构

```
fortune_master/
├── apps/
│   ├── web/                    # Flutter Web 配置
│   ├── ios/                    # iOS Runner
│   ├── android/                # Android Runner
│   └── desktop/                # 可选（macOS/Windows）
├── lib/
│   ├── core/                   # 路由、主题、本地化、错误处理
│   ├── data/                   # API client, Supabase client, repositories
│   ├── domain/                 # 业务模型 (BaziChart, TarotReading, ...)
│   ├── features/
│   │   ├── auth/               # 登录/注册
│   │   ├── bazi/               # 八字模块
│   │   ├── ziwei/              # 紫微模块
│   │   ├── iching/             # 周易模块
│   │   ├── tarot/              # 塔罗模块
│   │   ├── qimen/              # 奇门模块
│   │   ├── horoscope/          # 占星模块
│   │   ├── community/          # 社区（分享/评论/点赞）
│   │   ├── paywall/            # 订阅/付费墙
│   │   └── profile/            # 个人中心
│   ├── l10n/                   # i18n 资源（en, zh-CN）
│   └── shared/                 # 通用 widgets
├── supabase/
│   ├── functions/              # Edge Functions（Fortune Engine）
│   ├── migrations/             # SQL migrations
│   └── seed.sql                # 种子数据
├── assets/
│   ├── i18n/
│   ├── tarot/                  # 78 张韦特塔罗图片
│   ├── bazi/                   # 八字天干地支图标
│   └── images/
├── test/
└── pubspec.yaml
```

### 6.2 状态管理

- **Riverpod**（推荐）：类型安全、可测试、适合复杂业务。
- **go_router**：声明式路由。

### 6.3 跨端差异处理

```dart
// 平台分支示例
import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  // 支付：Web 走 Stripe，App 走 IAP
  static PaymentGateway get paymentGateway =>
      isWeb ? StripeGateway() : NativeIAPGateway();

  // 分享：App 走原生 share sheet，Web 走 navigator.share / 复制链接
  static Future<void> share(String text) async {
    if (isWeb) return WebShare.share(text);
    return NativeShare.share(text);
  }
}
```

---

## 7. 术数 × App 矩阵（首发 Medium 8）

| # | 术数 | 英文名 | iOS App 名 | Bundle ID | 主要 fork 来源 | 复杂度 |
|---|---|---|---|---|---|---|
| 1 | 八字 | Bazi (Four Pillars) | Fortune Master · Bazi AI | app.fortunemaster.bazi | bazi + paipan | ⭐⭐⭐ |
| 2 | 紫微斗数 | Zi Wei Dou Shu | Fortune Master · ZiWei | app.fortunemaster.ziwei | taibu + mingyu | ⭐⭐⭐⭐ |
| 3 | 周易六爻 | I Ching | Fortune Master · I Ching | app.fortunemaster.iching | ichingshifa | ⭐⭐⭐ |
| 4 | 梅花易数 | Plum Blossom | Fortune Master · Mei Hua | app.fortunemaster.meihua | ichingshifa (复用) | ⭐⭐⭐ |
| 5 | 塔罗 | Tarot | Fortune Master · Tarot AI | app.fortunemaster.tarot | tarot-api + chatgpt-tarot | ⭐⭐ |
| 6 | 奇门遁甲 | Qi Men | Fortune Master · Qi Men | app.fortunemaster.qimen | taibu + mingyu | ⭐⭐⭐⭐⭐ |
| 7 | 西占星 | Western Astrology | Fortune Master · Horoscope | app.fortunemaster.astro | Astrologer-API | ⭐⭐⭐ |
| 8 | 周公解梦 | Dream | Fortune Master · Dream | app.fortunemaster.dream | 自建（基于《周公解梦》原文） | ⭐⭐ |

**扩展（Phase 3）**：大六壬、太乙神数、小六壬、风水（住宅）、面相、手相、雷诺曼、姓名学、灵签、择日、MBTI（共 15+ 种）。

---

## 8. 三层付费模型

```
┌─────────────────────────────────────────────────────────────────┐
│  Tier 0 · FREE（基础排盘）                                          │
│  ─────────────────────────────────────                          │
│  · 输入生日/卦题/问题                                               │
│  · 服务端跑算法（Edge Function），不调 LLM                            │
│  · 返回结构化排盘结果（图表 + 关键符号 + 简短算法生成的解读模板）          │
│  · 用户可看基础图表、无解读                                          │
│  · 不需要登录                                                       │
└─────────────────────────────────────────────────────────────────┘
                              │ 看广告解锁 ↓
┌─────────────────────────────────────────────────────────────────┐
│  Tier 1 · BRIEF（轻度 LLM 解读）                                     │
│  ─────────────────────────────────────                          │
│  · 用户看完 15 秒激励视频                                            │
│  · 调 DeepSeek（short prompt，约 500 tokens）                      │
│  · 生成 200 字精炼解读                                               │
│  · 每用户每天 3 次免费额度                                           │
└─────────────────────────────────────────────────────────────────┘
                              │ 付费/订阅 ↓
┌─────────────────────────────────────────────────────────────────┐
│  Tier 2 · DETAILED（深度解读 + PDF）                                 │
│  ─────────────────────────────────────                          │
│  · 单次解锁：$1.99 / 次                                             │
│  · 订阅：$4.99/月 或 $39.99/年（7 折）                              │
│  · 调 DeepSeek（long prompt，约 3000 tokens）                       │
│  · 生成完整结构化解读（性格/事业/财运/感情/健康 + 流年流月）              │
│  · PDF 导出 + 分享卡                                                │
│  · 无限解读额度                                                     │
└─────────────────────────────────────────────────────────────────┘
```

### 8.1 收入预估（保守）

| 阶段 | DAU | 免费→付费转化 | 月订阅用户 | ARPU | 月收入 |
|---|---|---|---|---|---|
| Month 3（MVP 上线） | 500 | 1% | 5 | $5 | $25 |
| Month 6 | 3,000 | 2% | 60 | $5 | $300 |
| Month 12 | 20,000 | 3% | 600 | $5 | $3,000 |
| Month 18 | 80,000 | 4% | 3,200 | $5 | $16,000 |

> 注：算命类 App 的付费转化率通常显著高于普通工具 App（行业经验 3-8%），保守取下限。

### 8.2 成本预估

| 项目 | 月成本 (估算) |
|---|---|
| Cloudflare Pages + Workers | $5 - $50 |
| Supabase Pro | $25 |
| DeepSeek API (1 万次深度解读) | $20 - $50 |
| AdMob（净收入为正） | -$广告收入- |
| Apple Developer Fee | $8.3/月（年付摊销） |
| Domain + 邮件 | $5 |
| **总计** | **$60 - $150/月** |

> 盈亏平衡：约 12-30 个付费用户即可覆盖成本。

---

## 9. 分阶段路线图

### Phase 0：准备（Week 0-1）✅ 已完成
- [x] 调研 GitHub 上 17+ 算命开源项目
- [x] 与用户对齐 12 项关键决策
- [x] Fork 14 个核心仓库到 `davard123`
- [x] 输出本方案文档

### Phase 1：Web MVP（Week 2-8）
**目标：跑通全链路，上线 Cloudflare Pages 公开访问**

| Week | 任务 | 验收 |
|---|---|---|
| 2 | Supabase 项目初始化、Auth 配置、Postgres schema migration | DB 可连接、Auth 可注册 |
| 3 | Edge Functions 框架搭建、`/chart/bazi` + `/chart/tarot` 两个最小端点 | 两个排盘 API 跑通 |
| 4 | Flutter 客户端脚手架、路由、登录页、首页术数列表 | 首页可加载、登录可用 |
| 5 | 八字模块（输入生日→排盘→模板解读）+ 塔罗模块（三牌阵） | 两个核心功能 demo |
| 6 | DeepSeek 集成（brief 解读）、广告位（AdMob Web） | 解读可生成、广告位显示 |
| 7 | 6 个术数补齐（紫微、六爻、梅花、奇门、占星、周公解梦） | 8 个术数全部 demo |
| 8 | UI 打磨、英文/简中 i18n、Privacy/ToS、Cloudflare 部署 | 生产环境上线 |

**Week 8 验收**：8 个术数均可演示，付费墙、广告、注册/登录、社区分享完整流程跑通。

### Phase 2：iOS + Android App（Week 9-16）
**目标：复用 Flutter 代码库，打包首个 App「Fortune Master · Tarot AI」上架**

| Week | 任务 | 验收 |
|---|---|---|
| 9 | iOS 工程配置（Xcode、Bundle ID、Provisioning） | `flutter build ios` 通过 |
| 10 | IAP 集成（RevenueCat SDK） | 沙盒购买可走通 |
| 11 | Apple/Google 登录集成、推送通知（OneSignal） | 登录可用、推送可收 |
| 12 | 塔罗 App 完整开发（重用 Web 代码） | iOS build 通过 |
| 13 | App Store 截图、文案、Privacy、TestFlight 内测 | 内测可用 |
| 14 | 提交审核（Apple 平均 24-48h）→ 上架 | App Store 上线 |
| 15-16 | Google Play 上架同一 App | 双端上线 |

**Week 16 验收**：塔罗 App iOS + Android 双端上线，首批用户可下载。

### Phase 3：App 矩阵扩展（Week 17-32）
**目标：根据 Web/iOS 数据，挑选 Top 3-5 高频术数，做成独立 App**

依据 Web/iOS 数据决定顺序（候选顺序：八字 → 紫微 → 周易 → 奇门 → 占星）。
每个 App 复用 Phase 1-2 模板，约 1-2 周一个。

**Week 32 验收**：5+ 个独立 App 上架。

### Phase 4：增长与变现优化（Week 33+）
- 投放 Apple Search Ads（核心 ASO 词：tarot, bazi, iching, horoscope, fortune teller）
- 引入推荐计划（邀请解锁高级解读）
- 引入小工具（每日一签、每日运势推送）
- 接入 SEO 友好的 Web 落地页（blog posts：什么是八字？塔罗牌怎么解读？）
- Reddit/Quora/小红书内容营销
- KOL 合作（海外玄学 KOL）

---

## 10. 关键技术风险与对策

| 风险 | 概率 | 影响 | 对策 |
|---|---|---|---|
| Apple 审核拒绝（认为 fortune telling 是骗局） | 中 | 高 | 在所有页面加 "for entertainment only"、订阅前必须勾选同意条款；参考同类型 App Co-Star、Sanctuary 的过审经验 |
| DeepSeek API 限流/涨价 | 中 | 中 | 准备 GPT-4o-mini / Claude Haiku 作为备份；Prompt 压缩；缓存重复问题 |
| fork 项目 License 冲突 | 低 | 高 | 全部用 MIT/Apache-2.0 项目；重写为 TS 不直接 import fork 源码；保留 LICENSE 文件 |
| 算命算法争议（错排盘被投诉） | 中 | 中 | 免责声明 + 不接付费预测、不承诺结果 |
| 跨端 Flutter Web 性能 | 中 | 中 | 用 `flutter build web --web-renderer html` 或 CanvasKit；图片懒加载；启用 SSR |
| 个人开发者单点故障 | 高 | 高 | 关键代码放 GitHub；3-2-1 备份；Supabase 自动备份 |

---

## 11. 仓库组织建议（davard123）

```
davard123/
├── fortune-master/                     # 主代码库（Flutter 客户端 + Supabase 配置）
├── fortune-engine/                     # Fortune Engine 独立仓库（如需独立部署）
├── docs/                               # 本方案 + 后续开发文档
│   └── plans/
│       └── 2026-07-01-fortune-master-design.md
├── (14 个 fork 项目作为 upstream 同步源)
```

---

## 12. 立即可执行的下一步

### 本周（Week 1）
1. ✅ 已完成：fork 14 个仓库（10 个成功 + 4 个待补）
2. ⏳ 完成剩余 fork：lawreka/ascii-tarot、MinatoAquaCrews/nonebot_plugin_tarot、jeremytarling/python-tarot、zhaoolee/cyber-fortune-telling
3. ⏳ 创建 Supabase 项目 + Apple Developer App IDs
4. ⏳ 初始化 Flutter 项目（`flutter create fortune_master`）
5. ⏳ 启动 Cloudflare Pages 仓库

### Week 2 起按 Phase 1 路线图执行

---

## 13. 附录 A：剩余 fork 操作（待执行）

```bash
gh repo fork lawreka/ascii-tarot --clone=false
gh repo fork MinatoAquaCrews/nonebot_plugin_tarot --clone=false
gh repo fork jeremytarling/python-tarot --clone=false
gh repo fork zhaoolee/cyber-fortune-telling --clone=false
```

> `g-battaglia/Astrologer-API` 已从待补清单移除：§5.2.1 实测确认 `taibu-core/astrology` 可直接覆盖西占星需求，不再需要这个 fork。
> 上述命令因工具调度中断未完成，可在 Week 1 收尾时统一执行。

---

## 14. 附录 B：试用阶段 LLM 方案 · FreeLLMAPI 集成

### 14.1 选型动机

试用阶段（Phase 0-1，约 0-8 周）直接购买 DeepSeek 等付费 API 存在以下问题：
- 单次调试成本累积
- 试用用户少、付费转化未验证、ROI 不确定
- 多模型对比（A/B Test）需求——付费 API 多模型切换成本高

**FreeLLMAPI**（[tashfeenahmed/freellmapi](https://github.com/tashfeenahmed/freellmapi)，⭐14.5k，MIT，2026-06 最新 v0.4.1）提供 OpenAI 兼容代理，将 16 个 LLM provider 的免费层叠合在一起，月 ~17 亿 tokens 免费额度。完美匹配试用阶段需求。

### 14.2 支持的 16+ 模型

| Provider | 代表模型 | 适用场景 |
|---|---|---|
| Google Gemini 2.5 Flash | 多模态输入、视觉 | 面相/手相识别 |
| Groq Llama 3.3 70B | 高速推理 | 快速解读 |
| Cerebras Qwen3 235B | 超快推理 | 实时卦象解读 |
| Mistral Large 3 | 欧洲语言 | 英语深度解读 |
| OpenRouter (21 个免费模型) | 多模型路由 | A/B Test |
| GitHub Models (GPT-4.1, GPT-4o) | 高质量通用 | 兜底主力 |
| Cloudflare Kimi K2 / GLM-4.7 | 中文优化 | 中文命理首选 |
| Z.ai (Zhipu) GLM-4.5 | 中文 SOTA | 深度中文解读 |
| HuggingFace Router (DeepSeek V4, Kimi K2.6) | 多模型路由 | 弹性补充 |
| Ollama Cloud | 多模型 | 离线/边缘场景 |
| Pollinations / LLM7 / Kilo / OVH | 匿名免费 | 备用兜底 |

### 14.3 集成架构（试用阶段）

```
Flutter Client
   ↓ HTTPS + JWT
Supabase Auth + Postgres
   ↓
Supabase Edge Functions (Fortune Engine)
   ├─ /v1/chart/*    (排盘算法 - 纯计算)
   └─ /v1/interpret  (解读 - 调用 LLM)
        ↓
FreeLLMAPI 代理层（自托管 docker）
   ├─ 16 个 provider 自动负载均衡
   ├─ 故障转移 (429/5xx → fallback chain)
   └─ 统一 API key (freellmapi-xxx)
        ↓
16 个 LLM provider 免费层
```

### 14.4 部署步骤

#### 步骤 1：本地/服务器部署 FreeLLMAPI

```bash
# 推荐方案：Docker 部署到自己 VPS 或本地
docker compose up -d
# 默认端口 3001，默认绑定 127.0.0.1

# 或者一键安装
curl -fsSL https://freellmapi.co/install.sh | bash
```

⚠️ **重要**：README 明确警告"不要暴露到公网"——所以 FreeLLMAPI 只能部署在你的私有网络里（本地开发机或个人 VPS），**不能直接给客户端调用**。Supabase Edge Functions 在你的私有网络里调用它即可。

#### 步骤 2：在 FreeLLMAPI 仪表盘添加 API Keys

访问 `http://localhost:3001`，注册账号，进入 **Keys** 页面，至少添加：
- **Google AI Studio Key**（Gemini 免费）→ https://aistudio.google.com/apikey
- **GitHub Token**（GitHub Models 免费）→ https://github.com/settings/tokens
- **Groq API Key**（Llama 高速）→ https://console.groq.com/keys
- **OpenRouter Free Key**（21 模型聚合）→ https://openrouter.ai/keys
- **Cloudflare Account ID + Token**（CF AI 免费）→ https://dash.cloudflare.com/profile/api-tokens

#### 步骤 3：获取统一 API Key

FreeLLMAPI 生成 `freellmapi-xxxx` 格式的统一 key，用于客户端访问。

#### 步骤 4：Supabase Edge Function 集成

```typescript
// supabase/functions/v1/interpret/index.ts
import OpenAI from 'openai';

// 指向你自托管的 FreeLLMAPI
const freellmapi = new OpenAI({
  apiKey: Deno.env.get('FREELLMAPI_KEY'), // freellmapi-xxx
  baseURL: Deno.env.get('FREELLMAPI_URL'), // http://freellmapi.internal:3001/v1
});

export async function interpret(
  system: string,
  chartData: object,
  tier: 'brief' | 'detailed' | 'pdf',
  locale: 'en' | 'zh-CN'
) {
  // 模型路由策略（按语言 + 复杂度选择）
  const model = pickModel(system, tier, locale);

  const prompt = buildPrompt(system, chartData, tier, locale);

  const completion = await freellmapi.chat.completions.create({
    model,
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.8,
    max_tokens: tier === 'pdf' ? 3000 : tier === 'detailed' ? 1500 : 500,
  });

  return completion.choices[0].message.content;
}

function pickModel(system: string, tier: string, locale: string) {
  // 中文命理 → GLM-4.5 / Kimi K2 / DeepSeek V4
  if (locale === 'zh-CN') {
    if (tier === 'brief') return 'zhipu/glm-4.5';        // 快速且够用
    if (tier === 'detailed') return 'cloudflare/kimi-k2'; // 长文本
    return 'huggingface/deepseek-v4';                     // PDF 深度
  }
  // 英文 → GPT-4o / Llama 3.3
  if (tier === 'brief') return 'github/gpt-4o-mini';
  if (tier === 'detailed') return 'github/gpt-4.1';
  return 'groq/llama-3.3-70b';
}
```

### 14.5 模型路由策略

| Tier | 语言 | 推荐模型 | 备注 |
|---|---|---|---|
| Brief (Tier 1) | zh-CN | zhipu/glm-4.5 | 快速、低成本、中文佳 |
| Brief | en | github/gpt-4o-mini | 英文快、便宜 |
| Detailed (Tier 2) | zh-CN | cloudflare/kimi-k2 | 长文本 SOTA |
| Detailed | en | github/gpt-4.1 | 质量稳定 |
| PDF | zh-CN | huggingface/deepseek-v4 | 深度推理 |
| PDF | en | groq/llama-3.3-70b | 高速长文本 |

### 14.6 已知限制与对策

| 限制 | 影响 | 对策 |
|---|---|---|
| **仅供个人实验** | 不可商用 | 见 14.6.1 硬开关；Phase 1 免责声明中明确"测试阶段" |
| **无 SLA** | 延迟波动 | 客户端显示 fallback 状态；超时降级到模板解读 |
| **智力随时间下降**（高峰期降级小模型） | 解读质量波动 | A/B Test 不同 provider；记录用户反馈用于选优 |
| **顶级模型无免费层**（无 GPT-5 / Opus） | 复杂推理受限 | PDF 报告分级：标准版用免费模型，Premium 版用 DeepSeek 付费 |
| **ToS 风险**（Gemini、Cohere） | 商用违规风险 | 见 14.6.1 硬开关前完成所有 provider ToS 审计；规避 Cohere、谨慎 Gemini |
| **本地部署** | 增加运维负担 | 用 Docker；纯本地自测阶段（`supabase functions serve`）不需要暴露 |
| **不能直连公网** | 云端 Edge Function 连不上本地服务 | 见 14.6.1，本地自测和云端部署要分开处理 |

### 14.6.1 商业化切换的硬开关（关键）

FreeLLMAPI 及其聚合的多数免费层 ToS 只允许"个人实验"用途。当前 Phase 1 仅是自测（自己验证模型解读效果），未对外开放，符合个人实验场景，**不构成 ToS 冲突**。但这个安全边界不是按"Phase 2 / Week 9"这个时间点划定的，而是按**是否有非本人用户在用**划定：

> **硬性规则**：只要广告位/付费墙对任何非本人用户开放（哪怕只是邀请几个朋友内测），当天必须切换到付费 API（DeepSeek 或其他可商用方案），不得因为赶进度继续用 FreeLLMAPI 免费层。

另外，这个边界还牵涉部署环境本身：自测如果完全在本地 CLI（`supabase functions serve`）里跑，本地 Edge Function 和本地/同网络的 FreeLLMAPI 之间没有可达性问题；但**一旦把 Edge Function 部署到 Supabase 云端项目**（哪怕只是自己远程连测），云端 Edge Function 就无法再访问绑定 `127.0.0.1` 或未暴露的本地/VPS 服务。届时需要二选一：
- 用 Cloudflare Tunnel（或类似方案）做**带鉴权**的公网暴露，接受这就是"暴露"，并加访问控制/限流；或
- 跳过 FreeLLMAPI 代理层，Edge Function 直连允许服务端调用的免费层 API（如 Groq、Google AI Studio 官方 SDK）。

建议在开始云端联调前先确定选哪条路，而不是等部署失败时再决定。

### 14.7 切换到 DeepSeek 的迁移路径（Phase 2）

准备触发 14.6.1 的硬开关时，只需修改 Supabase Edge Function 中的 `pickModel()` 和 base URL：

```typescript
// Phase 2 切换后
const deepseek = new OpenAI({
  apiKey: Deno.env.get('DEEPSEEK_API_KEY'),
  baseURL: 'https://api.deepseek.com/v1',
});

function pickModel(system: string, tier: string, locale: string) {
  return 'deepseek-chat'; // 统一 DeepSeek V3
}
```

**业务代码完全不需要改动**——这就是 OpenAI 兼容的好处。

### 14.8 月度成本对比

| 阶段 | LLM 月成本 (假设 1 万次深度解读) | 备注 |
|---|---|---|
| Phase 1（试用） | **$0** | FreeLLMAPI 免费层 |
| Phase 2（正式） | **$20 - $50** | DeepSeek 付费 |
| Phase 3（规模化） | **$200 - $500** | DeepSeek + GPT-4o 备份 |

### 14.9 引用

- GitHub: https://github.com/tashfeenahmed/freellmapi
- README License: MIT
- 项目状态：v0.4.1, 2026-06-20, ⭐14.5k, 活跃维护
- 推荐原因：OpenAI 兼容、16 provider 聚合、智能故障转移、A/B Test 友好

---

**文档版本**：v1.1（含 FreeLLMAPI 试用方案）
**下次评审**：Phase 1 完成后（Week 8 末）
**联系人**：davard123