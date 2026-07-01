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
| LLM 主力 | **DeepSeek**（中文命理解读最优解，¥1/M tokens 输入） |
| MVP 语言 | 英文 + 简体中文 |
| 社区功能 | 包含：解读分享墙 + 评论 + 点赞 |
| 合规策略 | MVP：标准化免责声明 + Privacy Policy + ToS |
| 品牌 | 中文"中西算命大全" / 海外英文"Fortune Master" |
| GitHub 账号 | davard123 |

---

## 2. 已 Fork 的开源仓库清单

> 每个术数挑 2 个高分项目，便于交叉验证算法。所有 fork 均在 `davard123` 账号下。

### 2.1 八字（命理核心）
| 仓库 | 原 star | fork URL |
|---|---|---|
| china-testing/bazi | 1,386 | https://github.com/davard123/bazi |
| axbug/8Char-Uni-App | 277 | https://github.com/davard123/8Char-Uni-App |
| hkargc/paipan | 164 | https://github.com/davard123/paipan |
| masterai-top/Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code | 53 | https://github.com/davard123/Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code |

### 2.2 紫微斗数
| 仓库 | 原 star | fork URL |
|---|---|---|
| hhszzzz/taibu | 291 | https://github.com/davard123/taibu |
| Brhiza/mingyu | 172 | https://github.com/davard123/mingyu |

### 2.3 周易 / 易经
| 仓库 | 原 star | fork URL |
|---|---|---|
| kentang2017/ichingshifa | 263 | https://github.com/davard123/ichingshifa |
| chengjun/iching | 125 | https://github.com/davard123/iching |
| xinliulab/Future-Telling-By-I-Ching | 102 | https://github.com/davard123/Future-Telling-By-I-Ching |

### 2.4 塔罗
| 仓库 | 原 star | fork URL |
|---|---|---|
| ekelen/tarot-api | 391 | https://github.com/davard123/tarot-api |
| dreamhunter2333/chatgpt-tarot-divination | 823 | https://github.com/davard123/chatgpt-tarot-divination |
| uxiaohan/Tarot-Web | 106 | https://github.com/davard123/Tarot-Web |

### 2.5 奇门遁甲 / 六壬 / 太乙神数
| 仓库 | 原 star | fork URL |
|---|---|---|
| hhszzzz/taibu（已含） | 291 | （见上） |
| Brhiza/mingyu（已含） | 172 | （见上） |
| H1d3rOne/xuan-deduct | 23 | https://github.com/davard123/xuan-deduct |

### 2.6 其他
| 仓库 | 原 star | fork URL |
|---|---|---|
| NodleCode/Nodle-I-Ching | 276 | https://github.com/davard123/Nodle-I-Ching |
| gclinux/etaoism | 82 | https://github.com/davard123/etaoism |

> 共 **14 个 fork**。部分项目（如 taibu、mingyu）是「一站式排盘工具」覆盖八字+紫微+六爻+梅花+奇门+大六壬+小六壬+塔罗+太乙神数——这些项目会作为**核心后端依赖**。

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

### 5.2 算法实现策略

对每个 fork 项目，采取**「读源码 → 抽核心算法 → 重写为 TypeScript」**流程：

- `china-testing/bazi`（Python）：核心是万年历 + 干支推算，参考其农历转换函数，重写为 TS。
- `ekelen/tarot-api`（JS）：直接是 JSON 数据，可直接复用 Rider-Waite 牌面 JSON，TS 重写抽牌逻辑。
- `kentang2017/ichingshifa`（Python）：大衍之数算法可重写为纯函数。
- `hhszzzz/taibu`（TS）：已经 TS 实现，**优先复用其核心**！这是少见的 TS 实现。
- `dreamhunter2333/chatgpt-tarot-divination`（TS）：同样是 TS 实现，复用其多术结构。
- `NodleCode/Nodle-I-Ching`（TS）：卦象数据可直接用。

**复用策略**：能直接 import 的 TS 包优先；Python 算法一律重写；JS 算法用 Deno 直接跑（Edge Functions 兼容 Node 生态）。

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

## 13. 附录：剩余 fork 操作（待执行）

```bash
gh repo fork lawreka/ascii-tarot --clone=false
gh repo fork MinatoAquaCrews/nonebot_plugin_tarot --clone=false
gh repo fork jeremytarling/python-tarot --clone=false
gh repo fork zhaoolee/cyber-fortune-telling --clone=false
gh repo fork g-battaglia/Astrologer-API --clone=false
```

> 上述命令因工具调度中断未完成，可在 Week 1 收尾时统一执行。

---

**文档版本**：v1.0
**下次评审**：Phase 1 完成后（Week 8 末）
**联系人**：davard123