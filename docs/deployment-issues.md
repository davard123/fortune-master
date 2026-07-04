# 部署问题诊断 · Fortune Master

> Last updated: 2026-07-04

## 1. 问题

部署到 `fortune.fopusha.com` 后:
- ✅ `/landing/` — 营销页正常
- ✅ `/landing/arts/bazi.html` — 子页正常
- ✅ `/privacy/`, `/terms/`, `/cookies/` — 法律页正常
- ❌ `/` — 浏览器只显示纯文本 `fortune_master`，没有 Flutter 内容，进程卡住或进入白屏

## 2. 实际症状

`curl -sS https://fortune.fopusha.com/` 返回:

```html
<!DOCTYPE html>
<html>
<head>
  ...
  <title>fortune_master</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

这是**正常的 Flutter Web 模板** — body 内是空的（所有 UI 由客户端 JS 渲染）。`<title>fortune_master</title>` 就是页面文本唯一可见的来源，浏览器开发者工具应能看到 `flutter_bootstrap.js` 请求，但加载后渲染链路断了。

## 3. 诊断结果

通过 `curl -I` 取响应头，发现以下三个会导致 Flutter SPA 启动失败的问题：

### 3.1 ⚠️ CSP 缺失关键指令

原 `_headers` 的 CSP:

```
Content-Security-Policy: default-src 'self'; 
  script-src 'self' 'unsafe-inline' 'unsafe-eval'; 
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; 
  font-src 'self' https://fonts.gstatic.com data:; 
  img-src 'self' data: https: blob:; 
  connect-src 'self' https://xjvoqpijrpjmgqkqwhqd.supabase.co wss://... ...; 
  frame-ancestors 'none'; base-uri 'self'; form-action 'self'
```

**缺失指令**：

| 指令 | 用途 | Flutter 影响 |
|---|---|---|
| `worker-src 'self' blob:` | 控制 Worker / SharedWorker 加载 | Flutter 启动 canvaskit 渲染所需的 WASM worker |
| `child-src 'self' blob:` | 控制 frame / Worker 通过内联方式创建 | Flutter 用 `new Worker(new Blob(...))` 启动时需要 |
| `script-src-elem` | 显式 `<script src>` 加载策略 | 现代浏览器与 `script-src` 区分 |
| `script-src-attr` | 内联事件处理 (onclick 等) | 兼容性 |
| `manifest-src 'self'` | 控制 web app manifest | Flutter Web 安装到桌面需要 |
| `connect-src blob:` | 允许 XHR / fetch 跨 blob: 协议 | Flutter wasm streaming 编译 |

### 3.2 ⚠️ `Cross-Origin-Resource-Policy: same-origin` 过严

Flutter Web canvaskit 渲染器在 Worker 里加载 WASM 时，会发出跨 origin resource request。
- **`same-origin`**: 严格，阻止 fetches
- **`cross-origin`**: 宽松，公开资源可被任意 origin 嵌入

### 3.3 ✓ 不是资源加载问题

```bash
curl -I https://fortune.fopusha.com/flutter_bootstrap.js       # 200 OK
curl -I https://fortune.fopusha.com/main.dart.js               # 200 OK
curl -I https://fortune.fopusha.com/canvaskit/canvaskit.js    # 200 OK
```

资源全部能拉到，问题在浏览器执行时的 CSP 拦截。

## 4. 修复

### 4.1 修改 `_headers`

**改前**:
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com data:; img-src 'self' data: https: blob:; connect-src 'self' https://xjvoqpijrpjmgqkqwhqd.supabase.co wss://xjvoqpijrpjmgqkqwhqd.supabase.co https://api.deepseek.com https://*.google-analytics.com https://*.googletagmanager.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self'
Cross-Origin-Resource-Policy: same-origin
```

**改后**:
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; script-src-elem 'self' 'unsafe-inline' 'unsafe-eval'; script-src-attr 'self' 'unsafe-inline'; worker-src 'self' blob:; child-src 'self' blob:; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com data:; img-src 'self' data: https: blob:; connect-src 'self' blob: data: https://xjvoqpijrpjmgqkqwhqd.supabase.co wss://xjvoqpijrpjmgqkqwhqd.supabase.co https://api.deepseek.com https://*.google-analytics.com https://*.googletagmanager.com; manifest-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'
Cross-Origin-Resource-Policy: cross-origin
```

### 4.2 部署步骤

**只需重新部署 `build/web/`（不需要重建 Flutter）**:

```bash
cd C:\Users\david\ZCodeProject

# Cloudflare Pages 直连 GitHub 的话:
git push origin master
# (Cloudflare Pages 会自动拉取重 build)

# 或手动 wrangler:
npx wrangler pages deploy build/web --project-name=fortune-master
```

### 4.3 验证

部署完成后，**直接看响应头**确认 CSP 生效:

```bash
curl -sI https://fortune.fopusha.com/ | grep -iE "content-security-policy|cross-origin"
```

应看到:

```
content-security-policy: default-src 'self'; script-src ...; worker-src 'self' blob:; ...
cross-origin-resource-policy: cross-origin
```

> ⚠️ Cloudflare Pages 边缘节点会缓存头部几分钟，验证不生效时:
> ```bash
> curl -sI -H "Cache-Control: no-cache" https://fortune.fopusha.com/
> ```
> 或换个时间再试。

最后浏览器开 `https://fortune.fopusha.com/`，DevTools → Console 应该:
- ✅ 没有 CSP 报错
- ✅ 看到 `Flutter` 启动 banner: "Starting..."
- ✅ 进入 App 首页（八门术数网格）

## 5. 学到

- Flutter Web + Cloudflare Pages 项目的 CSP 必须显式支持 worker / child-script src 与 blob URI
- 默认 canvas 渲染器走 WASM worker，需要 `Cross-Origin-Resource-Policy: cross-origin` 配合
- Flutter Web 模板 body 是空的，看到 `fortune_master` 文本是**正常现象** — 验证要看 DevTools Console 而不是 curl 输出

## 6. 后续优化

- [ ] Flutter build 时显式声明 `--web-renderer canvaskit`（目前是默认；如果以后想换 html 渲染器，需要重新评估 CSP）
- [ ] 监控 — 加入 Sentry / TrackJS 监听前端 CSP 违规
- [ ] 添加 `report-uri` / `report-to` 到 CSP，将违规上报，便于发现新阻拦