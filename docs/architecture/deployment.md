# 部署架构 · Fortune Master / 中西算命大全

> Last updated: 2026-07-01

## 1. 总览

Fortune Master 是一款 Flutter Web 应用（兼容 iOS / Android），由两个独立运行环境组成：

| 环境 | 用途 | 提供方 |
|---|---|---|
| **静态前端** | Flutter Web bundle（HTML / JS / WASM / 资源） | Cloudflare Pages |
| **Edge API** | 排盘 + AI 解读的 Deno 函数 | Supabase Edge Functions |

外部依赖：LLM 提供方（DeepSeek 生产 / 自部署开发）、RevenueCat / Stripe（订阅）、Supabase Auth + Postgres（持久化）。

```
┌──────────────────┐         HTTPS          ┌────────────────────────────┐
│   Flutter Web    │ ──────────────────────▶│ Cloudflare Pages (CDN)     │
│  (browser SPA)   │ ◀──── HTML / JS / ─────│  fortunemaster.pages.dev   │
└────────┬─────────┘                         └────────────────────────────┘
         │
         │ supabase.functions.invoke('chart-bazi' / 'chart-tarot' / ...)
         ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  Supabase Edge Functions  (Deno, npm:taibu-core@^3.4.0)                  │
│  ├─ _shared/cors.ts        ← ALLOWED_ORIGINS 白名单                       │
│  ├─ chart-bazi   ─┐                                                      │
│  ├─ chart-tarot   │  pure compute: post body → JSON chart                 │
│  ├─ chart-qimen  ─┘                                                      │
│  └─ interpret    ← LLM call (OpenAI-compatible)                           │
└────────┬─────────────────────────────────────────────────────────────────┘
         │
         │  HTTPS POST  /v1/chat/completions
         ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  LLM  (OpenAI-compatible)                                                │
│  - dev:  https://api.freellmapi.com/v1                                    │
│  - prod: https://api.deepseek.com/v1                                      │
└──────────────────────────────────────────────────────────────────────────┘
```

## 2. Cloudflare Pages（前端）

### 2.1 项目设置
- **项目名**：`fortune-master`
- **生产分支**：`main`
- **构建命令**：`flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- **构建输出目录**：`build/web`
- **根域**：`fortunemaster.app`（自定义） · **回退域**：`fortune-master.pages.dev`

### 2.2 关键文件（仓库根）

| 文件 | 作用 |
|---|---|
| `_headers` | 全局安全响应头（CSP / HSTS / X-Frame-Options / Permissions-Policy 等） |
| `_redirects` | `/privacy`, `/terms`, `/cookies` 301 重定向到子目录（让 SPA fallback 失效） |
| `wrangler.toml` | Pages 项目元数据（`name` / `compatibility_date`） |
| `web/` | 静态资源目录（legal pages、icons、favicon、manifest） |

### 2.3 SPA fallback 行为
Cloudflare Pages 默认对**任何不匹配静态文件的路径**返回 `index.html`，这正是我们要的 SPA 行为。但 `/privacy`, `/terms`, `/cookies` 这些**静态目录**需要明确：
- `/privacy` → `/privacy/`（301），随后 Cloudflare 直接服务 `web/privacy/index.html`。
- `/privacy.html` → `/privacy/`（301），处理旧链接。
- 中文版：`/privacy.zh.html`, `/terms.zh.html`, `/cookies.zh.html` 直接作为静态文件服务，不需要 fallback。

### 2.4 部署命令
```bash
# 一键：build + publish
cd /c/Users/david/ZCodeProject
cmd //c "set PATH=C:\flutter\bin;%PATH% && flutter build web --release"
npx wrangler pages deploy build/web --project-name=fortune-master
```

## 3. Supabase Edge Functions（API）

### 3.1 部署清单

| Function | 触发场景 | 运行时 |
|---|---|---|
| `chart-bazi` | 用户提交八字排盘 | Deno（supabase-edge-runtime-1.x） |
| `chart-tarot` | 塔罗牌抽取 | Deno |
| `chart-qimen` | 奇门遁甲排盘 | Deno |
| `interpret` | AI 解读（brief / detailed） | Deno + LLM fetch |

### 3.2 本地调试
```bash
supabase functions serve chart-bazi --no-verify-jwt   # 本地无 JWT
curl -X POST http://localhost:54321/functions/v1/chart-bazi \
  -H "Content-Type: application/json" \
  -d '{"locale":"en","birth_date":"1990-01-01","birth_time":"12:00","birth_city":"Beijing","gender":"male","tz":"Asia/Shanghai"}'
```

### 3.3 生产部署
```bash
supabase functions deploy chart-bazi chart-tarot chart-qimen interpret
supabase secrets set LLM_API_KEY=sk-... LLM_BASE_URL=https://api.deepseek.com/v1
```

### 3.4 环境变量

| 变量 | 用途 | 必需 |
|---|---|---|
| `LLM_API_KEY` | LLM 调用密钥 | 是（仅 interpret 函数） |
| `LLM_BASE_URL` | OpenAI 兼容端点 | 否（默认 `https://api.freellmapi.com/v1`） |
| `LLM_MODEL` | 模型名 | 否（默认 `deepseek-chat`） |

> ⚠️ interpret 函数有 localhost 守卫：`if (LLM_BASE_URL contains 'localhost' && Deno.env.get('ENV') === 'production') throw` 防止开发端点泄漏到生产。

### 3.5 CORS
所有函数统一通过 `supabase/functions/_shared/cors.ts` 输出 CORS 头，使用 **ALLOWED_ORIGINS 白名单** + `Vary: Origin`：
- `https://fortune-master.pages.dev`
- `https://fortunemaster.app`
- `http://localhost:8080`（本地 Flutter Web 开发）
- `http://localhost:3000`（本地前端 mock）

新增域名时改 `_shared/cors.ts` 一处即可，无需改各函数。

## 4. 数据库（Supabase Postgres）

| 表 | 用途 | 关键约束 |
|---|---|---|
| `profiles` | 用户档案 | RLS：仅本人可读写 |
| `chart_results` | 排盘结果（bazi / tarot / qimen / ...） | RLS：仅本人可读写 |
| `saved_interpretations` | 用户保存的 AI 解读 | RLS：仅本人可读写；按 tier 限制是否可保存 |
| `community_posts` | 社区帖子 | RLS：所有人可读，本人可写/删 |
| `community_comments` | 评论 | RLS：所有人可读，本人可写/删 |
| `subscriptions` | 订阅状态（RevenueCat / Stripe webhook 写入） | RLS：仅本人可读，写入仅 service_role |

> 所有表启用 Row Level Security。Anon key 仅能通过 RLS policy 暴露数据。

## 5. CI/CD

当前为手动部署（单个开发者）。推荐未来扩展：
1. GitHub Action：PR 时跑 `flutter analyze` + `flutter test`
2. main 合并后自动 `flutter build web` + `wrangler pages deploy`（用 `CLOUDFLARE_API_TOKEN` secret）
3. Edge Function 单独通过 `supabase functions deploy` 触发（或用 Supabase GitHub 集成直接挂载 `supabase/functions/`）

## 6. 监控与日志

- **前端**：Cloudflare Analytics（默认开启）；如启用 GA / Plausible 等需先更新 Cookie Notice。
- **Edge**：Supabase Dashboard → Edge Functions → Logs；建议接入 Logflare 或 Sentry。
- **数据库**：Supabase Dashboard → Database → Query Performance；开启 `pg_stat_statements`。
- **LLM 成本**：在 `interpret` 函数中打点 tokens 使用量，写入 `usage_logs` 表（计划中）。

## 7. 回滚策略

| 场景 | 操作 |
|---|---|
| 前端回滚 | Cloudflare Pages → Deployments → 选历史版本 → "Rollback to this deploy" |
| Edge Function 回滚 | `supabase functions deploy <name> --version <id>`（保留最近 10 个版本） |
| 数据库迁移回滚 | 永远只写向后兼容迁移；破坏性变更走两阶段部署（旧字段保留 → 数据回填 → 删旧字段） |

## 8. 故障演练清单（每月）

- [ ] Cloudflare Pages 部署失败 → 切回上次成功版本
- [ ] Edge Function 超时 → 检查 LLM 提供方状态页
- [ ] Supabase 数据库连接耗尽 → 检查连接池配置（默认 15）
- [ ] Auth 邮件未送达 → 检查 SMTP 配置（Resend / Postmark）