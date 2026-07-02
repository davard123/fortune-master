# Claude Design 集成说明 · Fortune Master

> Last updated: 2026-07-01

## 1. 背景

Claude Design 在 `C:\Users\david\ZCodeProject\web-prototype\index.html` 产出了一份完整的中文营销单页（504 行）：
- 八卦图（程序化绘制 + 旋转动画）+ 十二地支环
- 墨金主题（宣纸底 #efe4cb + 墨黑 #3d3122 + 金 #9a742e + 朱砂 #b43a3a + 玉 #4a7a64）
- 八门术数卡片 × 8（八字 / 紫微 / 周易 / 梅花 / 塔罗 / 奇门 / 西方占星 / 周公解梦）
- 八字命盘示例（四柱 + 五行 + AI 解读四段）
- 星空背景 canvas 动画

集成目标：把这份设计**拆为多页静态站**，挂在 `/landing/` 下，作为 Flutter SPA 的营销入口。

## 2. 拆分结构

```
web/landing/                              ← 新建, 整站根
├── index.html                            ← hero + 8 门卡片 + 命盘示例 (Claude Design 原貌拆分)
├── style.css                             ← 抽出 Claude Design 全部 CSS + 补 art-body 样式
├── landing.js                            ← 共享 JS: 星空 + 八卦 + 十二支 + 卡片数据
├── demo.html                             ← 命盘示例全屏 (从 index.html 的 #demo 抽出)
└── arts/                                 ← 8 个术数子页
    ├── bazi.html                         ← 八字
    ├── ziwei.html                        ← 紫微斗數
    ├── iching.html                       ← 周易六爻
    ├── meihua.html                       ← 梅花易數
    ├── tarot.html                        ← 塔羅
    ├── qimen.html                        ← 奇門遁甲
    ├── astro.html                        ← 西方占星
    └── dream.html                        ← 周公解夢
```

## 3. 路由与跳转

### 3.1 访问路径

| URL | 服务 | 说明 |
|---|---|---|
| `/` | Flutter SPA | 主应用 (默认行为) |
| `/landing/` | 静态 HTML | Claude Design 营销页 hero + 8 门 + 命盘示例 |
| `/landing/arts/bazi.html` | 静态 HTML | 八字介绍 |
| `/landing/arts/{ziwei,iching,meihua,tarot,qimen,astro,dream}.html` | 静态 HTML | 其余 7 门介绍 |
| `/landing/demo.html` | 静态 HTML | 命盘示例全屏 |
| `/#/bazi` | Flutter SPA | App 内八字排盘 (hash 路由) |
| `/#/tarot` 等 | Flutter SPA | 其余 7 门排盘 |

### 3.2 跳转关系

```
Flutter HomeScreen
  └─ AppBar [auto_stories] 按钮 → url_launcher → /landing/  (新 tab)

/landing/  (index.html)
  ├─ Hero CTA [開始占卜] → #arts (本页内滚动)
  ├─ nav [術數 Arts] → #arts
  ├─ nav [排盤 Demo] → demo.html
  ├─ nav [進入 APP] → /#/bazi (跳到 Flutter SPA 主页)
  └─ 8 张术数卡片 → /#/bazi 等 (跳到对应 Flutter 页面)

/landing/arts/bazi.html
  ├─ nav [← 術數一覽] → /landing/#arts
  ├─ nav [立即排盤] → /#/bazi
  └─ CTA banner [開始排盤 →] → /#/bazi
```

### 3.3 `_redirects` 调整

Cloudflare Pages 的 SPA fallback 默认会捕获所有未匹配路径返回 `index.html`，导致 `/landing/*` 也会被 Flutter 接管。需要显式 301 让路径落到 `landing/` 子目录下的静态文件：

```bash
/landing         /landing/         301
/landing.html    /landing/         301
```

`/landing/*` 下的 `arts/*.html` 和 `demo.html` 已经被目录结构直接映射，不需要额外规则。

## 4. 关键技术决策

### 4.1 为什么不用 `/landing.html` 而用 `/landing/`？
- Claude Design 原型 `<a class="brand" href="/landing/">` 用了绝对路径 → 选子目录方案
- 子目录方案 SEO 更友好（每个文件一个 URL）
- Cloudflare Pages 子目录 301 跳转语义清晰

### 4.2 为什么不用 i18n 框架？
- Claude Design 原型是中文繁体，文案已精雕（"問道於天"、"問道於天"、"鋒芒內蘊"）
- 营销页 v1 只做中文 → 避免机翻损坏文气
- Flutter SPA 已有完整 i18n (中英 ARB 17+ 键) → 英文用户走 App 路线

### 4.3 为什么不直接服务 `/` 给 marketing 页？
- Cloudflare Pages 只能从 `build/web` 托管
- `flutter build web` 总是覆盖根 `index.html` 为 Flutter 模板
- 解决方案：marketing 页放 `/landing/`，根路径仍为 SPA

### 4.4 为什么卡片用 `/#/{slug}` 而非 `/landing/arts/{slug}.html`？
- 卡片的设计意图是"立即排盘" → 进入 App 操作
- 子页 (`/landing/arts/{slug}.html`) 的设计意图是"了解这门术数" → 阅读
- 两种入口分工清晰：卡片 = 行动，子页 = 学习

### 4.5 字体策略
全部走 Google Fonts CDN，无本地嵌入：
```
Cinzel:wght@400;500;600             (英文衬线)
Ma Shan+Zheng                       (毛笔楷书, hero 标题)
Noto+Serif+SC:wght@300;400;500;600;700  (中文正文)
ZCOOL+XiaoWei                       (中文标题)
```

CSP 已在 `_headers` 允许 `fonts.googleapis.com` + `fonts.gstatic.com`。

## 5. 部署验证

### 5.1 本地预览

```bash
# 1. 跑 landing 静态页
cd C:\Users\david\ZCodeProject\web
python -m http.server 8080
# 浏览器打开 http://localhost:8080/landing/

# 2. 跑 Flutter SPA
cd C:\Users\david\ZCodeProject
flutter run -d chrome
# 浏览器打开 http://localhost:PORT/，AppBar 右上[auto_stories] 跳到 /landing/
```

### 5.2 部署后验证（Cloudflare Pages）

```bash
# 部署 Flutter Web
flutter build web --release
npx wrangler pages deploy build/web --project-name=fortune-master

# 验证路径
curl -I https://fortune-master.pages.dev/landing/
curl -I https://fortune-master.pages.dev/landing/arts/bazi.html
curl -I https://fortune-master.pages.dev/landing/demo.html
```

每个路径应返回 200 + `text/html`，而不是被 SPA fallback 接走。

## 6. 修改指南

### 6.1 修改 landing 页文案
- hero / 8 门 / 命盘示例 → `web/landing/index.html`（直接编辑 HTML 字符串）
- 单个术数子页 → `web/landing/arts/{slug}.html`
- 全局设计系统（颜色 / 字体 / 间距）→ `web/landing/style.css`（CSS variables 在 `:root`）
- 卡片 SVG emblem / 卡片数据 → `web/landing/landing.js` 的 `CARDS` 数组

### 6.2 添加第 9 个术数

```js
// 在 web/landing/landing.js 的 CARDS 数组末尾加
{
  slug: 'newart',
  zh: '新术数',
  en: 'NEW ART',
  hot: false,
  desc: '...',
  svg: `<g class="glow-on-hover" ...>...</g>`,
}
```

然后创建 `web/landing/arts/newart.html`（复制 `bazi.html` 模板，改 SLUG/TITLE/DESC/ZH_NAME/CRUMB_NAME/EN_NAME/APP_ROUTE/ONE_LINE_QUOTE/正文）。

最后在 HomeScreen 加新卡片：
```dart
_SystemItem('newart', l10n.systemNewart, l10n.systemNewartDesc, Icons.icon, const Color(0xFF...)),
```

### 6.3 修改 marketing CTA
- 主页 AppBar 按钮 → `lib/features/home/home_screen.dart` 的 AppBar `actions`
- 跳转 URL 改 `_openLanding()` 函数

## 7. 已知限制

- **手机端表格 / 大 demo**：在 ≤ 360px 屏宽下，命盘示例的 4 柱并排可能拥挤；CSS 已加 `@media (max-width: 720px)` 改 2 列，但单柱字会缩小
- **IE11 / 旧浏览器**：landing.js 用了 `URL.createObjectURL` 等 ES6+ 特性，不支持 IE
- **i18n**：仅中文；英文用户走 Flutter App（i18n 已就绪）
- **营销页内容**：v1 文案偏静态，未接入 CMS；改文案需手动编辑 HTML

## 8. 后续优化（未做）

- [ ] 营销页 EN 译版
- [ ] 暗色模式（CSS variables 已就绪，加 `@media (prefers-color-scheme: dark)` 一组变量覆盖即可）
- [ ] 8 个术数详情页加入用户案例 / 真实排盘截图
- [ ] 加 OG meta / Twitter Card（提升社交分享预览效果）
- [ ] 把 marketing 入口从 AppBar 改成 hero banner（更醒目）
- [ ] demo.html 加入"换一组示例数据"按钮（动态切换命主）