# Fortune Master · 中西算命大全馆 · 项目完整汇总

> **本文件用途**：项目完整上下文汇总，供其他 agent 阅读理解全貌
> **创建日期**：2026-07-01
> **作者**：davard123
> **GitHub**：https://github.com/davard123
> **状态**：Phase 0 完成（调研 + 决策 + Fork + 方案文档），等待 Phase 1 执行

---

## 📌 目录

1. [项目背景与目标](#1-项目背景与目标)
2. [市场调研：GitHub 算命项目 Star Top 10](#2-市场调研github-算命项目-star-top-10)
3. [理论依据分析](#3-理论依据分析)
4. [关键决策（Brainstorming 结果）](#4-关键决策brainstorming-结果)
5. [已 Fork 的开源项目清单](#5-已-fork-的开源项目清单)
6. [完整技术架构](#6-完整技术架构)
7. [术数 × App 矩阵](#7-术数--app-矩阵)
8. [三层付费模型](#8-三层付费模型)
9. [数据模型（Postgres）](#9-数据模型postgres)
10. [Fortune Engine API 设计](#10-fortune-engine-api-设计)
11. [Flutter 客户端架构](#11-flutter-客户端架构)
12. [FreeLLMAPI 试用方案（核心创新）](#12-freellmapi-试用方案核心创新)
13. [分阶段路线图（32 周）](#13-分阶段路线图32-周)
14. [风险与对策](#14-风险与对策)
15. [成本与收益预估](#15-成本与收益预估)
16. [立即可执行的下一步](#16-立即可执行的下一步)
17. [仓库组织与文件结构](#17-仓库组织与文件结构)

---

## 1. 项目背景与目标

### 1.1 一句话定位

> 一个面向海外华人 / 英语圈的「一站式玄学 App 大全馆」，把 8~15 种中西算命术数做成 Flutter 跨端产品（Web + iOS + Android 同源代码库），免费排盘、广告解锁轻度解读、订阅/付费解锁深度报告 + PDF 导出。

### 1.2 业务背景

- 用户观察到 GitHub 上有大量「赛博算命」开源项目但分散、缺乏商业化产品
- 借力 LLM + Flutter 跨端 + 海外 App Store 生态，把这些开源算法包装成商业产品
- **市场切入点**：海外华人圈 + 玄学爱好者（西方塔罗、占星等）

### 1.3 商业目标

- **Phase 1**（0-8 周）：Web MVP 验证商业模式
- **Phase 2**（9-16 周）：首个 App「Fortune Master · Tarot AI」上架
- **Phase 3**（17-32 周）：扩展到 5+ 独立 App
- **长期**：8-15 种术数全覆盖，月收入目标 $3k-$16k

---

## 2. 市场调研：GitHub 算命项目 Star Top 10

> 通过 `gh search repos` 多关键词检索（赛博算命 / 算命 / 八字 / 紫微 / 周易 / I-Ching / 占卜 / 风水 / taro / horoscope astrology）按 star 数排序后筛选去重。

| 排名 | 项目 | ⭐ Stars | 🍴 Forks | 语言 | 类别 |
|------|------|---------|---------|------|------|
| 1 | [china-testing/bazi](https://github.com/china-testing/bazi) | **1,386** | 469 | Python | 八字排盘 |
| 2 | [dreamhunter2333/chatgpt-tarot-divination](https://github.com/dreamhunter2333/chatgpt-tarot-divination) | **823** | 222 | TypeScript | AI 算命（多术） |
| 3 | [ekelen/tarot-api](https://github.com/ekelen/tarot-api) | **391** | 118 | JavaScript | 韦特塔罗牌 REST API |
| 4 | [hhszzzz/taibu](https://github.com/hhszzzz/taibu) | **291** | 68 | TypeScript | 高精度 AI 算命工具 |
| 5 | [NodleCode/Nodle-I-Ching](https://github.com/NodleCode/Nodle-I-Ching) | **276** | 30 | TypeScript | I-Ching NFT / 区块链 |
| 6 | [axbug/8Char-Uni-App](https://github.com/axbug/8Char-Uni-App) | **277** | 108 | Vue | 八字排盘 (UniApp) |
| 7 | [kentang2017/ichingshifa](https://github.com/kentang2017/ichingshifa) | **263** | 110 | Python | 周易筮法 |
| 8 | [chengjun/iching](https://github.com/chengjun/iching) | **125** | 42 | JavaScript | 易经 Python 蓍草卦 |
| 9 | [xinliulab/Future-Telling-By-I-Ching](https://github.com/xinliulab/Future-Telling-By-I-Ching) | **102** | 32 | Python | 易经算卦 |
| 10 | [dsh0416/quantum-i-ching](https://github.com/dsh0416/quantum-i-ching) | **96** | 17 | Jupyter | 量子易经 |

**关键发现**：
- 算命项目 star 数普遍 **100-1500 之间**，远低于主流 AI 项目，说明这是**蓝海细分市场**
- 综合性「一站式排盘」项目（`hhszzzz/taibu`、`Brhiza/mingyu`、`dreamhunter2333`）star 数高
- 大部分项目 License 是 MIT/Apache，重写为 TS 商业化无版权风险
- 西方占星、面相、手相的**高质量开源项目稀少**——需要自建或付费 API（如 Swiss Ephemeris）

---

## 3. 理论依据分析

> 这是产品定位和营销文案的理论基础。每个术数都有完整理论体系。

### 3.1 八字命理（四柱命理）
- **代表项目**：`china-testing/bazi`（1,386 ⭐，最高分）
- **理论依据**：北宋徐子平完善的**四柱命理学**——把出生年、月、日、时各配一对天干地支（共四柱八字），依据阴阳五行（木火土金水）生克、十神（正官/偏财/食神…）、神煞、大运流年推算命运。
- **技术核心**：万年历 + 干支推算 + 真太阳时换算。

### 3.2 紫微斗数
- **代表项目**：`hhszzzz/taibu`、`masterai-top` 综合系统
- **理论依据**：起源于北宋的**紫微斗数**——以出生年支定十四主星在十二宫的飞布，加上四化（化禄/权/科/忌）推算命宫、财帛宫、官禄宫等十二宫人事。
- **特点**：多变量命理符号系统，能容纳的信息密度比八字更大。

### 3.3 周易/易经（I Ching）
- **代表项目**：`kentang2017/ichingshifa`、`chengjun/iching`、`xinliulab/Future-Telling-By-I-Ching`、`dsh0416/quantum-i-ching`
- **理论依据**：
  - **大衍之数 / 蓍草占卜**（最古老）
  - **京房易 / 金钱卦**（三枚铜钱摇六次）
  - **梅花易数**：邵雍所创，按起卦时间或外应起卦，重"体用生克"
- **技术特点**：六十四卦恰好对应 6 bit 二进制——这是西方程序员觉得很酷的点。

### 3.4 塔罗牌（Tarot）
- **代表项目**：`dreamhunter2333/chatgpt-tarot-divination`（823 ⭐）、`ekelen/tarot-api`（391 ⭐）
- **理论依据**：源自 15 世纪欧洲的**韦特-史密斯塔罗体系**（Rider-Waite-Smith，78 张），通过牌阵（凯尔特十字、三牌阵、单牌）抽牌。
- **现代理论背书**：荣格派心理学的「共时性原理」。

### 3.5 AI 多术整合（赛博算命）
- **代表项目**：`dreamhunter2333/chatgpt-tarot-divination`、`hhszzzz/taibu`、`Brhiza/mingyu`
- **理论依据**：**「符号 + LLM」**——所有传统术数只做排盘（生成符号化数据），把"四柱/卦象/牌阵"当作**结构化 Prompt**，让 LLM 做自然语言解读。

### 3.6 其他支线
- **奇门遁甲**：古代军事占卜，时家奇门/日家奇门
- **大六壬 / 太乙神数**："三式"之二
- **风水**：环境对人影响，户型图分析
- **命名学（姓名五格）**：日本熊崎氏五格剖象法
- **面相 / 手相**：图像 → LLM 解读
- **占星（Western Astrology）**：需要 Swiss Ephemeris 专业天文库

### 3.7 算命效果真实评估（理性结论）

1. **排盘准确性极高**：纯算法，不会出错
2. **解读质量参差**：取决于 LLM Prompt
3. **可重复性差**：同一问题多次解读结果不同
4. **科学性为零**：所有项目都未通过对照实验
5. **真正价值**：娱乐 + 文化体验 + Prompt 工程展示

---

## 4. 关键决策（Brainstorming 结果）

> 通过 13 轮 AskUserQuestion 与用户对齐，全部已确认。

| # | 维度 | 决策 |
|---|------|------|
| 1 | 发布市场 | **海外** App Store（美/港/日）+ 全球 Web |
| 2 | Apple 资质 | ✅ 已有付费个人/公司账号 |
| 3 | 运作模式 | 免费 + 广告解锁 + 订阅/付费解锁深度报告 |
| 4 | 战略路径 | Web 与 App **并行**（非串行） |
| 5 | 技术栈 | **Flutter 全栈**（代码复用最大化） |
| 6 | 部署 | Web 用 **Cloudflare Pages + Workers** |
| 7 | 后端 | **Supabase BaaS** |
| 8 | 算法集成 | **API 化重写**为 Supabase Edge Functions |
| 9 | LLM 主力 | **Phase 1 试用**：[FreeLLMAPI](https://github.com/tashfeenahmed/freellmapi)（16 个免费 LLM 聚合）<br>**Phase 2+ 正式**：[DeepSeek](https://platform.deepseek.com)（中文命理 SOTA） |
| 10 | MVP 范围 | **Medium 8 种术数**首发 |
| 11 | MVP 语言 | 英文 + 简体中文 |
| 12 | 社区功能 | **包含**：解读分享墙 + 评论 + 点赞 |
| 13 | 合规策略 | MVP：标准化免责声明 + Privacy Policy + ToS |
| 14 | 品牌 | 中文："中西算命大全" / 海外英文：**Fortune Master** |
| 15 | GitHub 账号 | **davard123** |

### 4.1 三层付费设计（用户最核心的原创想法）

```
┌─────────────────────────────────────────────────────────────────┐
│  Tier 0 · FREE（基础排盘）                                          │
│  · 输入生日/卦题/问题                                               │
│  · 服务端跑算法（Edge Function），不调 LLM                            │
│  · 返回结构化排盘结果（图表 + 关键符号 + 算法生成的解读模板）            │
│  · 不需要登录                                                       │
└─────────────────────────────────────────────────────────────────┘
                              │ 看广告解锁 ↓
┌─────────────────────────────────────────────────────────────────┐
│  Tier 1 · BRIEF（轻度 LLM 解读）                                     │
│  · 用户看完 15 秒激励视频                                            │
│  · 调 DeepSeek（short prompt，约 500 tokens）                      │
│  · 生成 200 字精炼解读                                               │
│  · 每用户每天 3 次免费额度                                           │
└─────────────────────────────────────────────────────────────────┘
                              │ 付费/订阅 ↓
┌─────────────────────────────────────────────────────────────────┐
│  Tier 2 · DETAILED（深度解读 + PDF）                                 │
│  · 单次解锁：$1.99 / 次                                             │
│  · 订阅：$4.99/月 或 $39.99/年（7 折）                              │
│  · 调 DeepSeek（long prompt，约 3000 tokens）                       │
│  · 生成完整结构化解读（性格/事业/财运/感情/健康 + 流年流月）              │
│  · PDF 导出 + 分享卡                                                │
│  · 无限解读额度                                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. 已 Fork 的开源项目清单

> 所有 fork 已在 `davard123` 账号下，共 **15 个仓库**（11/15 通过本会话完成，4 个待补）。License 列已于 2026-07-01 通过 GitHub API 逐一核实（见 §5.9），**不再是未验证假设**。

### 5.1 八字（命理核心）
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| china-testing/bazi | 1,386 | https://github.com/davard123/bazi ✅ | ⚠️ 无 LICENSE 文件、README 未声明 |
| axbug/8Char-Uni-App | 277 | https://github.com/davard123/8Char-Uni-App ✅ | GPL-3.0（copyleft，谨慎使用） |
| hkargc/paipan | 164 | https://github.com/davard123/paipan ✅ | WTFPL（宽松） |
| masterai-top/Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code | 53 | https://github.com/davard123/Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code ✅ | ⛔ 自定义"MIT with Commercial Restrictions"，**明确禁止商用** |

### 5.2 紫微斗数
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| hhszzzz/taibu | 291 | https://github.com/davard123/taibu ✅ | 仓库根目录 **AGPL-3.0-only**；仅 `packages/core`（即 npm 包 `taibu-core`）单独声明 **MIT** |
| Brhiza/mingyu | 172 | https://github.com/davard123/mingyu ✅ | ⚠️ 无 LICENSE 文件、README 未声明 |

### 5.3 周易 / 易经
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| kentang2017/ichingshifa | 263 | https://github.com/davard123/ichingshifa ✅ | MIT ✅ |
| chengjun/iching | 125 | https://github.com/davard123/iching ✅ | MIT ✅ |
| xinliulab/Future-Telling-By-I-Ching | 102 | https://github.com/davard123/Future-Telling-By-I-Ching ✅ | ⚠️ 无 LICENSE 文件、README 未声明 |

### 5.4 塔罗
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| ekelen/tarot-api | 391 | https://github.com/davard123/tarot-api ✅ | ⚠️ 无 LICENSE 文件、README 未声明 |
| dreamhunter2333/chatgpt-tarot-divination | 823 | https://github.com/davard123/chatgpt-tarot-divination ✅ | MIT（仅 README 声明，无独立 LICENSE 文件） |
| uxiaohan/Tarot-Web | 106 | https://github.com/davard123/Tarot-Web ✅ | ⚠️ 无 LICENSE 文件、README 未声明 |

### 5.5 奇门遁甲 / 六壬 / 太乙神数
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| hhszzzz/taibu（已含） | 291 | （见上） ✅ | 见 5.2 |
| Brhiza/mingyu（已含） | 172 | （见上） ✅ | 见 5.2 |
| H1d3rOne/xuan-deduct | 23 | https://github.com/davard123/xuan-deduct ✅ | MIT ✅ |

### 5.6 其他
| 仓库 | 原 star | fork URL | License（已核实） |
|---|---|---|---|
| NodleCode/Nodle-I-Ching | 276 | https://github.com/davard123/Nodle-I-Ching ✅ | GPL-3.0（copyleft，谨慎使用） |
| gclinux/etaoism | 82 | https://github.com/davard123/etaoism ✅ | ⚠️ 无 LICENSE 文件、README 未声明 |

### 5.7 待补 fork（Week 1 收尾时执行）
```bash
gh repo fork lawreka/ascii-tarot --clone=false
gh repo fork MinatoAquaCrews/nonebot_plugin_tarot --clone=false
gh repo fork jeremytarling/python-tarot --clone=false
gh repo fork zhaoolee/cyber-fortune-telling --clone=false
```

> `g-battaglia/Astrologer-API` 已从待补清单移除：§10.2.1 实测确认 `taibu-core/astrology` 可直接覆盖西占星需求，不再需要这个 fork。

### 5.8 关键发现（已修订，2026-07-01 实测）

- `hhszzzz/taibu` 的核心算法已拆成独立发布的 npm 包 `taibu-core`（MIT，v3.4.0），覆盖 bazi/ziwei/qimen/taiyi/daliuren/liuyao/meihua/tarot/astrology/xiaoliuren/almanac —— **实测确认可直接 `npm install` 调用，覆盖 Medium-8 里除周公解梦外的全部术数**，详见 §10.2。
- ~~"所有项目 License 均为 MIT/Apache，重写无版权风险"~~ **已证伪**：15 个 fork 里只有 5 个是宽松许可（MIT ×4、WTFPL ×1），其余为 copyleft（GPL-3.0 ×2）、明确禁止商用（masterai-top 自定义许可 ×1）、或完全无声明（7 个仓库只有 README 无 LICENSE 文件）。详见 §5.9。
- 因此原"14 个 fork 逐一读源码重写"的策略已废弃，改为"以 `taibu-core` 为主力 SDK、其余 fork 仅作理论/交叉验证参考、不直接复制代码"。

### 5.9 License 核查结论（2026-07-01，GitHub API 实测，非假设）

原方案多处断言"全部 MIT/Apache-2.0，重写无版权风险"，实测结果并非如此（明细见上方各表）。**对本方案实际影响很小**，因为核心算法已改用 `taibu-core`（npm 包，MIT，独立于 `taibu` 仓库根目录的 AGPL-3.0）——**不要从 `taibu` 仓库根目录（`src/`、`supabase/`、`public/` 等）复制任何代码，只用发布到 npm 的 `taibu-core` 包**，就不会触碰 AGPL 条款。其余 fork 定位为"备用/交叉验证参考"：
- 无 License 声明的仓库——不要直接复制代码或数据，只能参考实现思路。
- `masterai-top/...`——明确禁止商用，需要从"可复用清单"里剔除，只能当纯理论参考读。
- GPL-3.0 的两个（8Char-Uni-App、Nodle-I-Ching）——copyleft，不打算开源自己代码的话不要直接复制。

---

## 6. 完整技术架构

### 6.1 系统架构图

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
│                 试用阶段（Phase 1）：FreeLLMAPI 自托管                │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │   FreeLLMAPI 代理 (Docker 本地或 VPS, 端口 3001)          │     │
│  │   16 个 LLM provider 自动负载均衡 + 故障转移                 │     │
│  │   统一 API key: freellmapi-xxx                            │     │
│  └─────────────────────────────────────────────────────────┘     │
│         │  Gemini 2.5  │  Groq Llama 3.3  │  GLM-4.5            │
│         │  Kimi K2  │  Cloudflare  │  DeepSeek V4              │
└──────────────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                 正式阶段（Phase 2+）：DeepSeek 付费 API              │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │   DeepSeek API - deepseek-chat                           │     │
│  │   中文命理 SOTA · ¥1/M tokens 输入 · ¥2/M 输出             │     │
│  └─────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────┘

外部服务：
┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
│  AdMob (广告) │  │ RevenueCat (IAP) │  Stripe (Web 订阅)  │
└──────────────┘  └──────────────┘  └──────────────────┘
```

### 6.2 关键架构原则

1. **算法即服务**：所有排盘算法在 Edge Functions 中实现，客户端永远拿不到原始 fork 代码（保护版权 + 避免篡改）
2. **LLM 永远在服务端**：客户端永远不直接调用 LLM（API Key 不暴露）
3. **数据库是事实来源**：用户的解读历史、评论、点赞都在 Postgres
4. **订阅/支付走平台合规通道**：iOS 走 StoreKit，Web 走 Stripe
5. **OpenAI 兼容**：Phase 1 → Phase 2 切换只改 base_url，业务代码 0 改动

---

## 7. 术数 × App 矩阵

### 7.1 首发 Medium 8（Phase 1 + Phase 2）

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

### 7.2 Phase 3 扩展（Full 15+）
- 大六壬、太乙神数、小六壬
- 风水（住宅）
- 面相、手相
- 雷诺曼、灵签、择日
- 姓名学
- MBTI

---

## 8. 三层付费模型

### 8.1 价值阶梯

| Tier | 名称 | 内容 | 用户成本 | LLM 调用 | 占比目标 |
|------|------|------|----------|----------|----------|
| 0 | **FREE** | 基础排盘（图表 + 模板解读） | $0 | ❌ 不调 LLM | 100% 用户 |
| 1 | **BRIEF** | 200 字精炼解读 | 看 15 秒广告 / 每日 3 次免费 | 短 Prompt ~500 tokens | 60% 用户 |
| 2 | **DETAILED** | 完整结构化解读 + PDF | $1.99/次 或 订阅 $4.99/月 | 长 Prompt ~3000 tokens | 8% 用户付费 |

### 8.2 收入预估（保守）

| 阶段 | DAU | 免费→付费转化 | 月订阅用户 | ARPU | 月收入 |
|---|---|---|---|---|---|
| Month 3（MVP 上线） | 500 | 1% | 5 | $5 | $25 |
| Month 6 | 3,000 | 2% | 60 | $5 | $300 |
| Month 12 | 20,000 | 3% | 600 | $5 | $3,000 |
| Month 18 | 80,000 | 4% | 3,200 | $5 | $16,000 |

> 算命类 App 付费转化率行业经验 3-8%，保守取下限。

---

## 9. 数据模型（Postgres）

> **出生信息生命周期原则**：`birth_lat/birth_lng`（精确经纬度）是高敏感 PII。`readings.input_payload` 里的原始出生信息应在排盘计算完成后尽快脱敏——只保留排盘结果 `chart_data` 长期存储，`input_payload` 不做原始经纬度的永久明文留存。Privacy Policy 需明确写出"生辰信息仅用于当次计算，服务端不永久存储原始经纬度明文"。

```sql
-- 用户档案
profiles (
  id            uuid PK REFERENCES auth.users,
  display_name  text,
  locale        text DEFAULT 'en',         -- 'en' | 'zh-CN' | 'zh-TW'
  birth_date    date,
  birth_time    time,
  birth_tz      text,
  birth_lat     numeric,
  birth_lng     numeric,
  gender        text,
  free_credits  int DEFAULT 5,
  is_premium    bool DEFAULT false,
  created_at    timestamptz DEFAULT now()
)

-- 排盘记录
readings (
  id              uuid PK,
  user_id         uuid REFERENCES profiles,
  system          text,                      -- 'bazi' | 'ziwei' | 'iching' | 'tarot' | ...
  input_payload   jsonb,
  chart_data      jsonb,                     -- 排盘结果
  tier            text,                      -- 'free' | 'ad_unlocked' | 'premium'
  llm_interp     text,                       -- LLM 生成的解读
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
  image_url       text,
  tags            text[],
  is_anonymous    bool DEFAULT false,
  created_at      timestamptz DEFAULT now()
)

-- 评论 / 点赞
post_reactions (
  post_id         uuid REFERENCES posts,
  user_id         uuid REFERENCES profiles,
  kind            text,                      -- 'like' | 'comment'
  body            text,
  created_at      timestamptz DEFAULT now(),
  PRIMARY KEY (post_id, user_id, kind)
)

-- 订阅状态
subscriptions (
  id              uuid PK,
  user_id         uuid REFERENCES profiles,
  plan            text,                      -- 'monthly' | 'yearly'
  expires_at      timestamptz,
  rc_original     jsonb,
  created_at      timestamptz DEFAULT now()
)

-- 解读配额使用
credit_logs (
  id              uuid PK,
  user_id         uuid REFERENCES profiles,
  delta           int,
  reason          text,                      -- 'free_signup' | 'ad_watched' | 'premium' | 'reading_used'
  reading_id      uuid REFERENCES readings,
  created_at      timestamptz DEFAULT now()
)
```

---

## 10. Fortune Engine API 设计

### 10.1 端点列表

```
POST /v1/chart/bazi           { birth: {...} }              → 八字排盘
POST /v1/chart/ziwei          { birth: {...} }              → 紫微排盘
POST /v1/chart/iching         { method: 'coins'|'yarrow' }  → 摇卦
POST /v1/chart/tarot          { spread: 'three'|'celtic' }  → 塔罗抽牌
POST /v1/chart/qimen          { datetime, ju }              → 奇门排盘
POST /v1/chart/liuren         { datetime, method }         → 大六壬
POST /v1/chart/horoscope      { birth, house }             → 西占星盘
POST /v1/chart/dream          { keyword }                  → 周公解梦查询
POST /v1/interpret            { reading_id, level: 'brief'|'detailed'|'pdf' }
  ↓ 内部调用 LLM，返回自然语言解读
GET  /v1/share/:reading_id    → 生成分享卡 SVG
POST /v1/export/pdf           { reading_id }                → 生成 PDF 报告
```

### 10.2 算法实现策略（已实测验证，2026-07-01）

**核心结论：不需要对 14 个 fork 逐一重写。`hhszzzz/taibu` 已把核心算法拆成独立发布的 npm 包 `taibu-core`（MIT License，v3.4.0，`npm install taibu-core` 即可），domains 覆盖：**

```
almanac, astrology, bazi, bazi-dayun, bazi-pillars-resolve,
daliuren, liuyao, meihua, qimen, taiyi,
xiaoliuren, ziwei, ziwei-flying-star, ziwei-horoscope, tarot
```

**基本覆盖了 Medium-8 里除周公解梦（本来就是自建）外的全部术数。** 实测（本地 Node，`npm install taibu-core` 后 `import 'taibu-core/qimen'` / `'taibu-core/bazi'`）：

- `calculateQimen({ year, month, day, hour, minute })`——**复杂度最高（⭐⭐⭐⭐⭐）的奇门遁甲**，零改动直接调用成功，返回完整九宫飞盘。
- `calculateBazi({ birthYear, birthMonth, birthDay, birthHour, gender })`——八字直接调用成功，返回完整四柱（十神/藏干/纳音/神煞/空亡）。
- `ziwei / liuyao / meihua / tarot / taiyi / daliuren / astrology / xiaoliuren` 的 `calculate*` 函数均可正常 `import`。

**原计划里"重写 `china-testing/bazi`（Python）、`kentang2017/ichingshifa`（Python）"可以直接砍掉**：
- `china-testing/bazi` 依赖 PyPI 包 `lunar_python` + 原生天文历库 `sxtwl`，无法在 Deno 里跑；但 `taibu-core` 用的是 `lunar_python` 的 JS 姊妹库 `lunar-javascript`（同一作者 6tail 维护），八字实现已更完整，直接弃用该 fork。
- `kentang2017/ichingshifa` 是 Streamlit 全栈 App，算法耦合在 UI 里，依赖 numpy/ephem，核心卦象数据库是二进制 pickle 文件（JS 无法直接读取）。`taibu-core` 已自带 `liuyao`（六爻）和 `meihua`（梅花易数）——如果这两种起卦法够用，同样可以跳过这个 fork；只有明确要做"大衍之数/蓍草占卜"这个特定流派时才需要单独移植。

**唯一需要在真实环境补测的风险点**：`taibu-core` 的奇门算法内部通过临时修改全局 `process.env.TZ` 来处理时区转换（配合互斥锁防并发干扰）。本地 Node 验证是通的，但 Supabase Edge Functions 跑的是 **Deno** 运行时，`process.env.TZ` 对 `Date` 计算是否同样生效需要在真正部署后（或至少 `deno run`）再测一次，不能假设 Node/Deno 行为一致。

**修订后的策略**：Week 3-7 排盘 Edge Function 开发，优先 `npm install taibu-core` 按 domain 逐个接线；`tarot-api`、`chatgpt-tarot-divination`、`Nodle-I-Ching` 等其余 fork 降级为备用/交叉验证参考，不再是必须移植对象；`china-testing/bazi`、`kentang2017/ichingshifa` 标记为弃用。

### 10.2.1 西占星验证 + 两个仍未覆盖的素材缺口（2026-07-01 实测）

- **西占星**：`taibu-core/astrology` 的 `calculateAstrology({ birthYear, birthMonth, birthDay, birthHour, birthMinute, longitude, latitude })` 实测调用成功，返回本命盘（十大行星、Placidus 宫位制、五种相位）+ 行运盘 + 相位列表——**`g-battaglia/Astrologer-API` 这个尚未完成的 fork 大概率不再需要**，已从 §5.7 待补清单移除。
- **塔罗牌面素材缺口**：`ekelen/tarot-api` 只有卡牌含义 JSON（`card_data.json`），`uxiaohan/Tarot-Web` 无牌面图片资源——两个 fork 都不提供 78 张牌的图片素材。韦特-史密斯（1909）原版画作在美国已进入公有领域，可用 Wikimedia Commons / sacred-texts.com 公版扫描图，不依赖任何一个 fork。
- **周公解梦内容缺口**：15 个 fork 里没有一个覆盖周公解梦原文数据，与原方案"自建"定位一致——需单独寻找《周公解梦》公版文本数据源，并甄别"整理版"是否有现代整理者版权。

### 10.3 Prompt 设计模板

```typescript
// Brief 解读（Tier 1，免费/广告解锁）
const briefPrompt = `
你是 Fortune Master 的资深命理师。基于以下${system}排盘数据：
${JSON.stringify(chart)}

请用${locale}给出一段 200 字以内的精炼解读，覆盖：
- 性格核心特征（2-3 点）
- 当前运势核心提示（1 点）
- 一句可执行的建议

语气温和、神秘但不神棍，**明确不构成决策建议**。
`;

// Detailed 解读（Tier 2，订阅/付费）
// 包含流年/流月/财运/事业/感情/健康六大维度

// PDF 报告（Tier 2 Premium）
// 生成结构化 JSON，前端模板渲染为 PDF
```

---

## 11. Flutter 客户端架构

### 11.1 项目结构

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
│   ├── domain/                 # 业务模型
│   ├── features/
│   │   ├── auth/               # 登录/注册
│   │   ├── bazi/               # 八字模块
│   │   ├── ziwei/              # 紫微模块
│   │   ├── iching/             # 周易模块
│   │   ├── tarot/              # 塔罗模块
│   │   ├── qimen/              # 奇门模块
│   │   ├── horoscope/          # 占星模块
│   │   ├── community/          # 社区
│   │   ├── paywall/            # 订阅/付费墙
│   │   └── profile/            # 个人中心
│   ├── l10n/                   # i18n（en, zh-CN）
│   └── shared/                 # 通用 widgets
├── supabase/
│   ├── functions/              # Edge Functions
│   ├── migrations/             # SQL migrations
│   └── seed.sql
├── assets/
│   ├── i18n/
│   ├── tarot/                  # 78 张韦特塔罗
│   ├── bazi/                   # 八字天干地支图标
│   └── images/
├── test/
└── pubspec.yaml
```

### 11.2 关键依赖（pubspec.yaml）

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1         # 状态管理
  go_router: ^14.2.0                # 声明式路由
  supabase_flutter: ^2.5.0          # Supabase 客户端
  openai_dart: ^0.4.5               # OpenAI 兼容客户端（FreeLLMAPI/DeepSeek）
  google_mobile_ads: ^5.1.0         # AdMob
  purchases_flutter: ^6.20.0        # RevenueCat IAP
  flutter_localizations:            # i18n
  intl: ^0.19.0
  pdf: ^3.11.1                      # PDF 生成
  printing: ^5.13.1                 # PDF 打印/分享
```

---

## 12. FreeLLMAPI 试用方案（核心创新）

> 这是本方案的最大创新点：**试用阶段 0 美元 LLM 成本**。

### 12.1 选型动机

试用阶段（Phase 0-1，约 0-8 周）直接购买 DeepSeek 等付费 API 存在以下问题：
- 单次调试成本累积
- 试用用户少、付费转化未验证、ROI 不确定
- 多模型对比（A/B Test）需求——付费 API 多模型切换成本高

**FreeLLMAPI**（[tashfeenahmed/freellmapi](https://github.com/tashfeenahmed/freellmapi)）
- ⭐ 14.5k · MIT · 2026-06 v0.4.1 最新
- OpenAI 兼容代理
- 16+ LLM provider 免费层聚合（月 ~17B tokens）
- 智能路由、自动故障转移（最多 20 次重试）
- 支持自定义 OpenAI 兼容端点

### 12.2 支持的 16+ 模型

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
| HuggingFace Router (DeepSeek V4) | 多模型路由 | 弹性补充 |
| Ollama Cloud | 多模型 | 离线/边缘场景 |
| Pollinations / LLM7 / Kilo | 匿名免费 | 备用兜底 |

### 12.3 集成架构

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

### 12.4 部署步骤

#### Step 1：自托管 FreeLLMAPI

```bash
# Docker（推荐）
docker compose up -d
# 默认端口 3001，默认绑定 127.0.0.1

# 或一键安装
curl -fsSL https://freellmapi.co/install.sh | bash
```

⚠️ **重要**：README 明确警告"不要暴露到公网"——所以 FreeLLMAPI 只能部署在你的私有网络里（本地开发机或个人 VPS），**不能直接给客户端调用**。

#### Step 2：申请各 Provider 免费 API Key

访问 FreeLLMAPI 仪表盘 `http://localhost:3001`，在 Keys 页面添加：

| Provider | 申请 URL |
|----------|----------|
| Google AI Studio | https://aistudio.google.com/apikey |
| GitHub Token | https://github.com/settings/tokens |
| Groq | https://console.groq.com/keys |
| OpenRouter | https://openrouter.ai/keys |
| Cloudflare | https://dash.cloudflare.com/profile/api-tokens |
| Cerebras | https://cloud.cerebras.ai/ |
| Mistral | https://console.mistral.ai/ |
| HuggingFace | https://huggingface.co/settings/tokens |
| Z.ai (Zhipu) | https://open.bigmodel.cn/ |

#### Step 3：获取统一 API Key

FreeLLMAPI 生成 `freellmapi-xxxx` 格式的统一 key。

#### Step 4：Supabase Edge Function 集成代码

```typescript
// supabase/functions/v1/interpret/index.ts
import OpenAI from 'openai';

// 指向你自托管的 FreeLLMAPI（私有网络）
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
    if (tier === 'brief') return 'zhipu/glm-4.5';
    if (tier === 'detailed') return 'cloudflare/kimi-k2';
    return 'huggingface/deepseek-v4';
  }
  // 英文 → GPT-4o / Llama 3.3
  if (tier === 'brief') return 'github/gpt-4o-mini';
  if (tier === 'detailed') return 'github/gpt-4.1';
  return 'groq/llama-3.3-70b';
}
```

### 12.5 模型路由策略

| Tier | 语言 | 推荐模型 | 备注 |
|---|---|---|---|
| Brief | zh-CN | zhipu/glm-4.5 | 快速、低成本、中文佳 |
| Brief | en | github/gpt-4o-mini | 英文快、便宜 |
| Detailed | zh-CN | cloudflare/kimi-k2 | 长文本 SOTA |
| Detailed | en | github/gpt-4.1 | 质量稳定 |
| PDF | zh-CN | huggingface/deepseek-v4 | 深度推理 |
| PDF | en | groq/llama-3.3-70b | 高速长文本 |

### 12.6 已知限制与对策

| 限制 | 影响 | 对策 |
|---|---|---|
| **仅供个人实验** | 不可商用 | 见 12.6.1 硬开关 |
| **无 SLA** | 延迟波动 | 客户端显示 fallback 状态；超时降级到模板 |
| **智力随时间下降**（高峰期降级小模型） | 解读质量波动 | A/B Test 不同 provider；记录用户反馈 |
| **顶级模型无免费层**（无 GPT-5 / Opus） | 复杂推理受限 | PDF 报告分级：标准版用免费模型，Premium 版用 DeepSeek 付费 |
| **ToS 风险**（Gemini、Cohere） | 商用违规风险 | 见 12.6.1 硬开关前完成 ToS 审计；规避 Cohere |
| **本地部署** | 增加运维负担 | Docker 一键；纯本地自测阶段不需要暴露 |
| **不能直连公网** | 云端 Edge Function 连不上本地服务 | 见 12.6.1，本地自测和云端部署要分开处理 |

### 12.6.1 商业化切换的硬开关（关键）

FreeLLMAPI 及聚合的多数免费层 ToS 只允许"个人实验"用途。当前阶段仅是自测（自己验证模型解读效果），未对外开放，符合个人实验场景，**不构成 ToS 冲突**。但这个边界不是按"到 Phase 2"这个时间点划定的，而是按**是否有非本人用户在用**划定：

> **硬性规则**：只要广告位/付费墙对任何非本人用户开放（哪怕只是邀请几个朋友内测），当天必须切换到付费 API，不得因为赶进度继续用免费层。

另外要注意部署环境的分界：自测如果完全在本地 CLI（`supabase functions serve`）里跑，本地 Edge Function 和本地/同网络的 FreeLLMAPI 之间没有可达性问题；但**一旦把 Edge Function 部署到 Supabase 云端项目**（哪怕只是自己远程连测），云端 Edge Function 就无法再访问绑定 `127.0.0.1` 或未暴露的本地/VPS 服务。届时需二选一：用 Cloudflare Tunnel 做带鉴权的公网暴露，或跳过代理层直连允许服务端调用的免费 API（如 Groq、Google AI Studio 官方 SDK）。建议开始云端联调前先确定选哪条路。

### 12.7 Phase 2 切换到 DeepSeek（业务代码 0 改动）

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

### 12.8 月度成本对比

| 阶段 | LLM 月成本 (假设 1 万次深度解读) | 备注 |
|---|---|---|
| Phase 1（试用） | **$0** | FreeLLMAPI 免费层 |
| Phase 2（正式） | **$20 - $50** | DeepSeek 付费 |
| Phase 3（规模化） | **$200 - $500** | DeepSeek + GPT-4o 备份 |

---

## 13. 分阶段路线图（32 周）

### Phase 0：准备 ✅ 已完成
- [x] 调研 GitHub 上 17+ 算命开源项目
- [x] 与用户对齐 13 项关键决策
- [x] Fork 10/14 个核心仓库到 `davard123`（4 个待补）
- [x] 输出完整方案文档

### Phase 1：Web MVP（Week 2-8）—— 当前阶段
**目标：跑通全链路，上线 Cloudflare Pages 公开访问**

| Week | 任务 | 验收 |
|---|---|---|
| 2 | Supabase 项目初始化、Auth 配置、Postgres schema migration | DB 可连接、Auth 可注册 |
| 3 | Edge Functions 框架搭建、`/chart/bazi` + `/chart/tarot` 两个最小端点 | 两个排盘 API 跑通 |
| 4 | Flutter 客户端脚手架、路由、登录页、首页术数列表 | 首页可加载、登录可用 |
| 5 | 八字模块（输入生日→排盘→模板解读）+ 塔罗模块（三牌阵） | 两个核心功能 demo |
| 6 | **FreeLLMAPI 集成**（brief 解读）、广告位（AdMob Web） | 解读可生成、广告位显示 |
| 7 | 6 个术数补齐（紫微、六爻、梅花、奇门、占星、周公解梦） | 8 个术数全部 demo |
| 8 | UI 打磨、英文/简中 i18n、Privacy/ToS、Cloudflare 部署 | 生产环境上线 |

### Phase 2：iOS + Android App（Week 9-16）
**目标：复用 Flutter 代码库，打包首个 App「Fortune Master · Tarot AI」上架**

| Week | 任务 | 验收 |
|---|---|---|
| 9 | iOS 工程配置（Xcode、Bundle ID、Provisioning） | `flutter build ios` 通过 |
| 10 | IAP 集成（RevenueCat SDK） | 沙盒购买可走通 |
| 11 | Apple/Google 登录集成、推送通知（OneSignal） | 登录可用、推送可收 |
| 12 | 塔罗 App 完整开发（重用 Web 代码） | iOS build 通过 |
| 13 | App Store 截图、文案、Privacy、TestFlight 内测 | 内测可用 |
| 14 | 提交审核 → 上架 | App Store 上线 |
| 15-16 | Google Play 上架同一 App | 双端上线 |

### Phase 3：App 矩阵扩展（Week 17-32）
**目标：根据 Web/iOS 数据，挑选 Top 3-5 高频术数，做成独立 App**

依据 Web/iOS 数据决定顺序（候选顺序：八字 → 紫微 → 周易 → 奇门 → 占星）。
每个 App 复用 Phase 1-2 模板，约 1-2 周一个。

### Phase 4：增长与变现优化（Week 33+）
- 投放 Apple Search Ads
- 引入推荐计划
- 引入小工具（每日一签、每日运势推送）
- SEO 友好的 Web 落地页
- Reddit/Quora/小红书内容营销
- KOL 合作（海外玄学 KOL）

---

## 14. 风险与对策

| 风险 | 概率 | 影响 | 对策 |
|---|---|---|---|
| Apple 审核拒绝（认为 fortune telling 是骗局） | 中 | 高 | 全页面加 "for entertainment only"；订阅前必须勾选同意条款；参考 Co-Star、Sanctuary 过审经验 |
| DeepSeek API 限流/涨价 | 中 | 中 | 准备 GPT-4o-mini / Claude Haiku 备份；Prompt 压缩；缓存重复问题 |
| FreeLLMAPI 限流/服务变更 | 中 | 中 | 多 provider 备份；快速切换到 DeepSeek |
| fork 项目 License 冲突 | 低 | 高 | 全部用 MIT/Apache-2.0；重写为 TS 不直接 import fork 源码；保留 LICENSE |
| 算命算法争议（错排盘被投诉） | 中 | 中 | 免责声明 + 不接付费预测、不承诺结果 |
| 跨端 Flutter Web 性能 | 中 | 中 | 用 `flutter build web --web-renderer html` 或 CanvasKit；图片懒加载 |
| 个人开发者单点故障 | 高 | 高 | 关键代码放 GitHub；3-2-1 备份；Supabase 自动备份 |

---

## 15. 成本与收益预估

### 15.1 月度运营成本

| 项目 | 月成本 (估算) |
|---|---|
| Cloudflare Pages + Workers | $5 - $50 |
| Supabase Pro | $25 |
| DeepSeek API (1 万次深度解读) | $20 - $50 |
| AdMob（净收入为正） | -$广告收入- |
| Apple Developer Fee | $8.3/月（年付摊销） |
| Domain + 邮件 | $5 |
| **总计** | **$60 - $150/月** |

> **盈亏平衡**：约 12-30 个付费用户即可覆盖成本。

### 15.2 收入曲线

| 时间 | DAU | 付费用户 | 月收入 |
|------|-----|----------|--------|
| Month 3 | 500 | 5 | $25 |
| Month 6 | 3,000 | 60 | $300 |
| Month 12 | 20,000 | 600 | $3,000 |
| Month 18 | 80,000 | 3,200 | $16,000 |

---

## 16. 立即可执行的下一步

### Week 1 收尾
```bash
# 补齐剩余 4 个 fork
gh repo fork lawreka/ascii-tarot --clone=false
gh repo fork MinatoAquaCrews/nonebot_plugin_tarot --clone=false
gh repo fork jeremytarling/python-tarot --clone=false
gh repo fork zhaoolee/cyber-fortune-telling --clone=false
gh repo fork g-battaglia/Astrologer-API --clone=false

# 部署 FreeLLMAPI
docker compose up -d

# 申请各 provider API key
# → Google AI Studio / Groq / OpenRouter / Cloudflare / GitHub

# 初始化 Flutter 项目
flutter create fortune_master
cd fortune_master && flutter pub add flutter_riverpod go_router supabase_flutter openai_dart

# 创建 Supabase 项目 + 配置 Auth + 跑 schema migration
```

### Week 2 起按 Phase 1 路线图执行

---

## 17. 仓库组织与文件结构

### 17.1 GitHub 组织（davard123）

```
davard123/
├── fortune-master/                     # 主代码库（Flutter 客户端 + Supabase 配置）
├── docs/                               # 文档（含本方案）
│   ├── plans/
│   │   └── 2026-07-01-fortune-master-design.md  # 原始方案 v1.1
│   └── fortune-master-handoff.md       # 本汇总文档
├── (14 个 fork 项目作为 upstream 同步源)
│   ├── bazi/
│   ├── 8Char-Uni-App/
│   ├── ichingshifa/
│   ├── iching/
│   ├── tarot-api/
│   ├── chatgpt-tarot-divination/
│   ├── taibu/
│   ├── mingyu/
│   ├── Future-Telling-By-I-Ching/
│   ├── paipan/
│   ├── Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code/
│   ├── Nodle-I-Ching/
│   ├── xuan-deduct/
│   ├── Tarot-Web/
│   └── etaoism/
```

### 17.2 本会话已交付

1. ✅ GitHub 算命项目调研（Top 10 star）
2. ✅ 理论依据分析（8 种主流术数）
3. ✅ 13 项关键决策对齐
4. ✅ 10/14 个仓库 fork 到 davard123
5. ✅ 完整方案文档（`docs/plans/2026-07-01-fortune-master-design.md` v1.1，已 git commit）
6. ✅ FreeLLMAPI 集成方案（关键创新点）
7. ✅ 三层付费模型设计
8. ✅ 32 周路线图 + 风险与对策 + 成本预估
9. ✅ **本汇总文档**（`docs/fortune-master-handoff.md`）

### 17.3 后续 Agent 可接力任务

- 初始化 Flutter 项目脚手架（`flutter create fortune_master`）
- 编写 Supabase Edge Function 第一个端点（八字排盘）
- 部署 FreeLLMAPI Docker + 申请 API keys
- 设计 UI/UX 视觉风格（神秘 + 极简 + 国际化）
- 配置 Apple Developer App IDs 和 Provisioning Profile
- 编写 i18n 资源文件（en.json, zh-CN.json）
- 设计 ASO 关键词与 App Store 截图

---

## 附录 A：关键参考链接

| 资源 | URL |
|------|-----|
| FreeLLMAPI (LLM 代理) | https://github.com/tashfeenahmed/freellmapi |
| DeepSeek API | https://platform.deepseek.com |
| Supabase | https://supabase.com |
| Flutter | https://flutter.dev |
| Cloudflare Pages | https://pages.cloudflare.com |
| RevenueCat | https://www.revenuecat.com |
| AdMob | https://admob.google.com |
| Apple Developer | https://developer.apple.com |
| 一站式排盘参考 | https://github.com/hhszzzz/taibu |
| 塔罗 API 参考 | https://github.com/ekelen/tarot-api |

---

**文档版本**：handoff-1.0
**最后更新**：2026-07-01
**作者**：davard123
**项目状态**：Phase 0 完成，等待 Phase 1 执行