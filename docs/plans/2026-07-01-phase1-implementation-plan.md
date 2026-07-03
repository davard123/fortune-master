# Fortune Master · Phase 1 实施计划（供执行 Agent 使用）

> **用途**：这是一份可直接执行的任务清单，基于 [design.md](2026-07-01-fortune-master-design.md) 和 [handoff.md](../fortune-master-handoff.md) 里已经验证过的结论（不是未经检验的假设）。执行 Agent 不需要重新调研或重新验证下面列出的技术判断，直接按顺序做即可；如果发现和本文档描述的事实不符，先停下来确认，不要凭直觉改方案。
> **前置阅读**：[design.md](2026-07-01-fortune-master-design.md) 全文（尤其 §2、§4、§5、§14）、[handoff.md](../fortune-master-handoff.md) 全文（尤其 §5、§9、§10、§12）。这两份文档已经包含全部背景、数据模型、API 设计、Prompt 模板，本文档不重复摘抄，只给"先做什么、注意什么"。
> **状态**：Phase 0 完成（调研 + 决策 + Fork + 方案文档 + 风险评审 + 技术验证）。本计划覆盖 Phase 1 Week 1-8（Web MVP）。

---

## 0a. 语言策略（澄清结论，与 design.md / handoff.md 一致）

- **MVP 双语**：英文 + 简体中文，**所有可见 UI 都要双语**，不只是 App Store 元数据
- **默认 locale**：根据用户浏览器 / 系统语言自动选择；无设置时 fallback 到 `en`
- **术语表**（关键术数官方英文译名）：
  | 中文 | 英文官方名 |
  |------|------------|
  | 八字 | Four Pillars of Destiny / Bazi |
  | 紫微斗数 | Zi Wei Dou Shu |
  | 周易六爻 | I Ching / Liu Yao |
  | 梅花易数 | Plum Blossom Numerology |
  | 奇门遁甲 | Qi Men Dun Jia |
  | 大六壬 | Da Liu Ren |
  | 太乙神数 | Tai Yi Shen Shu |
  | 西占星 | Western Astrology |
  | 周公解梦 | Zhou Gong Dream Interpretation |
- **语言切换模型**：用户偏好存 `profiles.locale`（已设计在 §4 schema 中）；LLM 解读 prompt 用此 locale 变量动态生成
- **繁体**：暂不单独翻译，需要时用 OpenCC 把简体自动转换（不做独立翻译）
- **资源文件**：用 Flutter 标准 ARB 格式（`lib/l10n/app_en.arb` + `lib/l10n/app_zh.arb`），CI 加 `flutter gen-l10n` 自动同步
- **不要**：纯中文为主 + 只翻译关键词（这是早期草稿的错误，已在 2026-07-01 修订为双语）

---

## 0. 五条硬约束（执行前必须记住，贯穿全程）

这五条来自方案评审和实测验证，是已经拍板的决定，不是待讨论选项：

1. **算法优先用 `taibu-core`（npm，MIT，v3.4.0+）**，不要按 design.md 早期版本描述的"逐个 fork 重写"去做。已实测确认 `calculateBazi`、`calculateQimen`、`calculateAstrology` 直接可调用；`ziwei/liuyao/meihua/tarot/taiyi/daliuren/xiaoliuren` 已确认可 import（未逐一跑通输出，接线时按 §2 逐个验证一次即可）。详见 design.md §5.2、§5.2.1。
2. **只用 npm 包，不要碰 `taibu` 仓库根目录代码**。`taibu` 仓库根目录（`src/`、`supabase/`、`public/` 等）是 AGPL-3.0，只有 `packages/core`（发布为 `taibu-core`）单独是 MIT。任何时候都通过 `npm install taibu-core` 引入，不要从 GitHub 仓库里复制粘贴代码。详见 design.md §2.7。
3. **FreeLLMAPI 商业化切换是硬开关，不是按周数**：只要广告位/付费墙对**任何非本人用户**开放（哪怕只是邀请朋友内测），当天必须切到付费 API（DeepSeek 或其他可商用方案）。如果打算把 Edge Function 部署到 Supabase 云端做联调（哪怕只是自己远程测），要先决定 Cloudflare Tunnel 暴露还是跳过代理直连服务端可调用的免费 API——本地 CLI 自测不受此影响。详见 design.md §14.6.1。
4. **出生信息生命周期**：`readings.input_payload` 里的原始出生经纬度用完即弃，只长期保留排盘结果 `chart_data`；不做原始经纬度的永久明文存储。Privacy Policy 里要写清楚这一点。详见 design.md §4。
5. **禁止复用的 fork**：`masterai-top/Bazi-Ziwei-Qimen-Dunjia-Divination-System-Source-Code` 的 LICENSE 明确禁止商用，不要参考或复制其代码/数据结构；GPL-3.0 的两个仓库（`axbug/8Char-Uni-App`、`NodleCode/Nodle-I-Ching`）和 7 个无 License 声明的仓库同样不要直接复制代码，只能读来理解思路。详见 design.md §2.7。

---

## 1. Week 1 收尾任务

1. 补齐剩余 4 个 fork（`Astrologer-API` 已从清单移除，不需要再 fork）：
   ```bash
   gh repo fork lawreka/ascii-tarot --clone=false
   gh repo fork MinatoAquaCrews/nonebot_plugin_tarot --clone=false
   gh repo fork jeremytarling/python-tarot --clone=false
   gh repo fork zhaoolee/cyber-fortune-telling --clone=false
   ```
2. 初始化 Flutter 项目脚手架：
   ```bash
   flutter create fortune_master
   cd fortune_master
   flutter pub add flutter_riverpod go_router supabase_flutter openai_dart google_mobile_ads purchases_flutter pdf printing intl
   ```
   目录结构按 design.md §6.1 组织（`lib/core`、`lib/data`、`lib/features/*`、`supabase/functions` 等）。
3. 创建 Supabase 项目，跑通 §4 的 Postgres schema migration（先按文档 SQL 建表，`readings.input_payload` 的字段设计要体现"用完即弃"原则——不要把 `birth_lat/birth_lng` 设计成一个会被永久索引查询的字段）。
4. 本地起一个 Node/TS scratch 项目验证 `taibu-core` 覆盖的 8 个 domain（bazi/ziwei/qimen/taiyi/daliuren/liuyao/meihua/tarot/astrology/xiaoliuren）各自的输入输出格式，为 Week 3 的 Fortune Engine API 设计做准备。参考调用方式：
   ```ts
   import { calculateBazi } from 'taibu-core/bazi';
   import { calculateQimen } from 'taibu-core/qimen';
   import { calculateAstrology } from 'taibu-core/astrology';
   // bazi 用 birthYear/birthMonth/birthDay/birthHour(/birthMinute)/gender
   // qimen 用 year/month/day/hour(/minute)
   // astrology 用 birthYear/.../longitude/latitude
   // 其余 domain 在真正接线前各自跑一次确认字段名，不要假设和 bazi/qimen 一致
   ```

## 2. Week 2：Supabase 基础设施

- Auth 配置（邮箱 + 预留 Apple/Google 登录位置）
- 按 design.md §4 建表：`profiles`、`readings`、`posts`、`post_reactions`、`subscriptions`、`credit_logs`
- **验收标准**：DB 可连接、Auth 可注册、`readings` 表的 `chart_data` 字段能正常写入 JSONB

## 3. Week 3：Fortune Engine API 框架 + 前两个端点

- 按 design.md §5.1 的端点设计（`POST /v1/chart/*`）起 Supabase Edge Functions 骨架
- 先跑通 `/v1/chart/bazi` 和 `/v1/chart/tarot` 两个最小端点，都调用 `taibu-core`
- **已解决（2026-07-02）**：`taibu-core/qimen` 在 Supabase Edge Runtime 下确认无法正确处理非 UTC 时区——内部依赖真实修改 `process.env.TZ`，Deno Edge Runtime 禁止运行时改环境变量，这是库的架构限制，不是参数问题，无法在调用方打补丁修复。已改为自实现拆补法排盘引擎，见 `supabase/functions/_shared/qimen-native.ts`，四柱用 `lunar-javascript` 直接算（不依赖系统时区）。局数/地盘已用完整实例逐宫验证；值符值使与星门旋转方向仍是中等置信度（中文资料存在流派分歧），**其余 domain 接线前如果也发现类似"结果不对但不报错"的情况，直接怀疑同样的 TZ 依赖问题，不要假设只有 qimen 才有**。详见 `docs/incidents/2026-07-01-taibu-core-qimen-empty.md`。

## 4. Week 4：Flutter 客户端脚手架

- 路由（go_router）、登录页、首页术数列表
- 接入 Analytics SDK（Firebase Analytics 或同等工具），至少埋点：排盘完成、广告观看、付费墙曝光、支付成功四个事件——这是为了让 §8.1 的转化率假设在 MVP 期间真的有数据可看，不要等到后面再补

## 5. Week 5-6：核心术数 + LLM 集成

- 八字模块（生日输入 → `taibu-core/bazi` 排盘 → 模板解读）+ 塔罗模块（三牌阵）
- **塔罗牌面图片素材缺口**：`taibu-core/tarot` 和已 fork 的 tarot 相关仓库都不提供 78 张牌的图片，需要单独找韦特-史密斯（1909，美国公有领域）的公版扫描图，来源如 Wikimedia Commons、sacred-texts.com
- LLM 集成：FreeLLMAPI 自托管（本地/VPS），按 design.md §14.4 的代码模板接入 `interpret` Edge Function。**接入时立刻按第 0 节第 3 条设置好切换开关的判断逻辑**（比如一个 feature flag：`isPublicRelease`，只要为 true 就强制走付费 API 分支），不要等到真的要上线那天才手忙脚乱改代码。
- 广告位（AdMob Web）

## 6. Week 7：剩余 6 个术数接线

按第 0 节第 1 条的方式，用 `taibu-core` 的 `ziwei/liuyao/meihua/qimen/astrology` domain（周公解梦除外）逐个接线。**接线前用 Week 1 第 4 步已经跑通的输入输出格式**，不要重新摸索。

- 周公解梦是唯一没有 fork 覆盖的术数，需要单独找《周公解梦》公版原文数据源（成书久远，早已进入公有领域，但要甄别市面"整理版"是否有现代整理者版权），做成简单的关键词查询表，不需要接 `taibu-core`

## 7. Week 8：打磨上线

- UI 打磨
- i18n：**英文 + 简体中文双 MVP**（与 design.md 决策表 §1 第 11 项、handoff.md §4.1 第 11 项一致）。执行清单：
  - 整站所有 UI 文案都要双语（不只是元数据）
  - 术语表（如八字 → "Four Pillars of Destiny"、紫微 → "Zi Wei Dou Shu"、奇门 → "Qi Men Dun Jia"、塔罗 → "Tarot"）要保持官方，必要时保留中文括注
  - 文案风格：英文友好解释型（小白也能懂），中文保留原生术语（不刻意英化）
  - 出生信息表单：双语标签 + 日期组件本地化（公历/农历切换器放在中文版主显、英文版默认隐藏）
  - 如果目标市场包含香港，加一步 OpenCC 简体转繁体的自动转换（zh-HK），不是重新翻译（不做繁体+简体两套独立翻译）
  - 关键参考资源：建 `lib/l10n/app_en.arb` 和 `lib/l10n/app_zh.arb`（ARB 格式由 Flutter `intl_translation` 工具链支持），CI 加 `gen-l10n` 自动生成 Dart 代码
- Privacy/ToS：落实第 0 节第 4 条（出生信息用完即弃），并覆盖社区 UGC 的举报机制（哪怕只是一个"举报"按钮 + 人工审核队列），不要上线一个完全没有内容审核路径的公开分享墙
- Cloudflare Pages 部署

---

## 验证方式

- 每完成一个 Edge Function 端点，先用 `curl` 或 Postman 直接打端点确认排盘结果字段完整、数值合理（可以拿一个已知的生日手工核对一下八字四柱是否正确）
- Flutter 端每完成一个模块，起 `flutter run -d chrome` 跑一遍完整用户路径（输入生日 → 排盘 → 广告解锁 brief 解读 → 付费墙）
- Week 3 的 Qimen 时区验证是本计划里唯一"设计阶段没能百分百确认、必须在真实 Deno 环境里补测"的技术风险点，验证结果（通过/需要 workaround）要更新回 design.md §14.6.1 或本文档，避免后续 Agent 重复踩坑
