# 法律页起草说明 · Fortune Master

> Last reviewed: 2026-07-01

## 1. 起草范围

本批起草共 **6 个 HTML 页 + 1 个共享 CSS**：

| 文件 | 语言 | 路径策略 |
|---|---|---|
| `web/privacy/index.html` | EN | 子目录 → `href="../legal/style.css"` |
| `web/privacy.zh.html` | 根级 | `href="legal/style.css"` |
| `web/terms/index.html` | EN | 子目录 → `href="../legal/style.css"` |
| `web/terms.zh.html` | 根级 | `href="legal/style.css"` |
| `web/cookies/index.html` | EN | 子目录 → `href="../legal/style.css"` |
| `web/cookies.zh.html` | 根级 | `href="legal/style.css"` |
| `web/legal/style.css` | 共享 | — |

> 路径策略不一致的原因：英文版走 `/privacy/` 风格（SEO 友好 + Cloudflare Pages 重定向），中文版走 `/privacy.zh.html` 风格（避免 i18n 子目录膨胀，更新简单）。

## 2. 关键设计取舍

### 2.1 Disclaimer / Entertainment-only 标注
**每一页顶部都加了显眼免责说明**（`.disclaimer-box` CSS class），原因是：
- 本服务涉及"占卜 / 命理"，容易被误用为医疗、法律、财务建议。
- AI 解读质量无法保证（可能幻觉、偏见、错误）。
- 多国法律（特别是 EU AI Act）对"内容生成型 AI 服务"在医疗/法律场景有特殊披露要求。
- 在 ToS §1 和 Privacy §1 同时出现，建立多重防线。

### 2.2 第三方处理者表
Privacy Policy §5 用表格列出 Supabase / Cloudflare / DeepSeek / RevenueCat 四家，明确：
- **目的**：避免 GDPR Art. 28 风险（必须披露处理者）。
- **数据类型**：让用户知道哪些数据"流出去"。
- **物理位置**：覆盖 GDPR / PIPL / LGPD 的"跨境传输"披露义务。

### 2.3 不收集敏感字段
我们**不收集**：
- 精确出生经纬度（仅城市级）—— 降低 fingerprint 风险，减小 re-identification 表面积。
- 全名（仅邮箱 local-part 作为默认显示名）。
- 设备指纹 / 广告 ID。

这些是有意为之的产品决策，写入 Privacy Policy §1.2 让用户知情。

### 2.4 Cookie 仅"严格必要"
当前 `app_locale` 严格来说是偏好类 Cookie（不是 auth 必需的），所以表中单独标注为 "Preference" 而非 "Strictly necessary"。这是诚实的分类。

### 2.5 责任上限
ToS §8 包含完整的免责声明与责任上限条款（USD 100 或 12 个月订阅费上限），这是单开发者项目的**风险控制必要项**。部分司法辖区不允许全部排除，所以加了"在适用法律允许的最大范围内"软化。

## 3. 联系人邮箱规划

| 用途 | 邮箱 |
|---|---|
| 隐私相关 | privacy@fortunemaster.app |
| 法律相关 | legal@fortunemaster.app |
| 安全漏洞 | security@fortunemaster.app |
| 客服 / 退款 | support@fortunemaster.app |

> 所有邮箱都映射到同一收件箱（Gmail with `+tag` aliases 或 Cloudflare Email Routing）。无需 4 个真实邮箱，但对外保持一致。

## 4. 国际化策略

- 英文版用 `lang="en"`，中文版用 `lang="zh-CN"`。
- 每页右上角有 `lang-switch` 链接（中英互跳）。
- 中文版独立 HTML（**没有用翻译框架**），原因：
  - 法律文本需要逐字审查，自动翻译会引入歧义。
  - 单开发者项目，6 页静态文本可控。
  - SEO 上中文版用 `.zh.html` 后缀清晰标识语言。

## 5. SEO

- 每页 `<meta name="robots" content="noindex, nofollow" />` — 法律页不需要被搜索引擎索引（也避免误导）。
- 有意义的 `<title>`（便于浏览器标签识别和屏幕阅读器）。
- 语义化 HTML5（`<header>`, `<footer>`, `<h1>~<h3>`, `<table>`）。

## 6. 样式（`web/legal/style.css`）

设计原则：
- **单列居中**，最大宽度 720px（易读）。
- **暖色背景 + 深色文字**，呼应"命理 / 玄学"主题但不浮夸。
- **CSS variables**（`--bg`, `--surface`, `--text`, `--border`, `--accent`），未来可加暗色模式 `@media (prefers-color-scheme: dark)` 一行解决。
- **响应式**：内边距 `clamp()`，手机端不溢出。
- **`.disclaimer-box`**：醒目高亮免责声明，不依赖 JS。
- **`.lang-switch`**：右上角固定，方便双语切换。

## 7. 待办（未来修订）

- [ ] **未成年人年龄**：根据目标市场确定最低年龄（当前 16 岁是保守值，部分地区可能要求 18+）。
- [ ] **AI Act 透明度披露**：若在 EU 上线，可能需要更详细的"AI 系统"披露章节。
- [ ] **数据导出 JSON 格式**：Privacy §8 承诺导出 JSON，需要在 `profile_screen.dart` 实现并校验。
- [ ] **DPA 模板**：企业用户可能需要签署数据处理协议，准备 DPA 模板。
- [ ] **儿童删除**：Privacy §9 提到，发现儿童注册请联系删除；需要一个接收端 → `child-safety@fortunemaster.app`（当前未启用）。
- [ ] **退款政策细化**：ToS §4.4 引用平台政策，建议在 Web 端建立独立的退款流程文档。

## 8. 审查记录

| 日期 | 操作 |
|---|---|
| 2026-07-01 | 初版起草（Privacy / Terms / Cookies × EN+ZH） |

## 9. 免责声明

**本人非律师**。本页和六份 HTML 均根据公开最佳实践（GDPR、CCPA、PIPL、AI Act 草案）和类似个人项目的范本起草。**强烈建议在正式上线前由具备您目标市场执业资格的律师审查。** 任何因依赖本页内容而产生的法律风险由运营者自行承担。