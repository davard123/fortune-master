# 中西算命大全 / Fortune Master

[![GitHub](https://img.shields.io/badge/GitHub-davard123-blue)](https://github.com/davard123)
[![Flutter](https://img.shields.io/badge/Flutter-3.27-blue)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-BaaS-3FCF8E)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> **一个面向海外华人 / 英语圈的「一站式玄学 App 大全馆」**——八字/紫微/周易/塔罗/奇门/占星/解梦 8 种术数，Flutter 跨端（Web + iOS + Android），免费排盘 + 广告解锁 + 订阅解锁深度解读 + PDF 导出。

---

## 🚀 当前进度

| Phase | 状态 |
|-------|------|
| Phase 0: 调研 + 决策 + Fork | ✅ 完成 |
| Phase 1: Web MVP (Week 1-8) | 🔄 进行中（Week 1 部分完成） |
| Phase 2: iOS/Android App | ⏳ 待启动 |

详见 `docs/plans/2026-07-01-phase1-implementation-plan.md`。

## 📂 项目结构

```
fortune-master/
├── docs/                              # 设计文档
│   ├── fortune-master-handoff.md      # 完整汇总 (920 行)
│   ├── plans/
│   │   ├── 2026-07-01-fortune-master-design.md  # 设计方案 (v1.1)
│   │   └── 2026-07-01-phase1-implementation-plan.md  # Week 1-8 执行计划
│   └── incidents/
│       └── 2026-07-01-taibu-core-qimen-empty.md  # 已知 Bug 记录
├── supabase/                          # 后端
│   ├── migrations/20260701000001_init_schema.sql  # 8 张表 + RLS
│   └── functions/
│       ├── chart-bazi/index.ts        # 八字排盘端点
│       └── chart-tarot/index.ts       # 塔罗抽牌端点
├── lib/                               # Flutter 客户端
│   ├── main.dart                      # 入口
│   ├── app.dart                       # MaterialApp + i18n 挂载
│   ├── core/
│   │   ├── env.dart                   # 环境变量
│   │   └── router.dart                # go_router 配置
│   ├── data/
│   │   └── repositories/fortune_repository.dart  # 与 Edge Function 通讯
│   ├── features/                      # 8 个模块 (bazi/tarot/iching/...)
│   └── l10n/                          # 双语 ARB
│       ├── app_en.arb                 # 49 个字符串
│       └── app_zh.arb                 # 49 个字符串
├── pubspec.yaml
├── l10n.yaml
└── .env.example
```

## 🛠️ 本地启动

### 前置条件

| 工具 | 版本 | 安装 |
|------|------|------|
| Flutter SDK | ≥ 3.27 | https://docs.flutter.dev/get-started/install/windows |
| Node.js | ≥ 20 | https://nodejs.org |
| Docker Desktop | ≥ 4.80 | https://www.docker.com/products/docker-desktop/ |
| Supabase CLI | latest | `npm i -g supabase` |
| Deno | ≥ 1.40 | https://deno.land |

### 步骤

```bash
# 1. 装依赖
flutter pub get

# 2. 启动本地 Supabase (需要 Docker Desktop 后台运行)
supabase start

# 3. 跑 migration
supabase db reset

# 4. 启 Edge Functions
supabase functions serve chart-bazi --no-verify-jwt
supabase functions serve chart-tarot --no-verify-jwt

# 5. (可选) Phase 1: 启动 FreeLLMAPI
docker compose -f docker-compose.freellmapi.yml up -d

# 6. Flutter Web 启动
flutter run -d chrome --web-port=8080 \
  --dart-define=SUPABASE_URL=http://localhost:54321 \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...   # 从 supabase status 取
```

## 📝 三层付费模型

| Tier | 内容 | 用户成本 | LLM |
|------|------|----------|-----|
| FREE | 基础排盘 | $0 | ❌ |
| BRIEF | 200 字解读 | 看广告 / 每日 3 次 | ✅ Short prompt |
| DETAILED | 深度解读 + PDF | $1.99/次 或 $4.99/月订阅 | ✅ Long prompt |

## 🌐 双语

- **英文**：Fortune Master (App Store 主标题)
- **简体中文**：中西算命大全
- **符文**：暂不支持，必要时用 OpenCC 自动转繁体（不做独立翻译）

## 🌐 部署 (Cloudflare Pages + Supabase Edge Functions)

### A. Cloudflare Pages（前端）

**方式 1（推荐）：Git 集成**

1. Cloudflare Dashboard → Workers & Pages → Create → Pages → Connect to Git → 选 `davard123/fortune-master`
2. **Build settings**:
   - Build command:
     ```
     flutter pub get && flutter build web --release --no-tree-shake-icons --dart-define=SUPABASE_URL=https://xjvoqpijrpjmgqkqwhqd.supabase.co --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
     ```
   - Build output directory: `build/web`
   - Root directory: `/` (项目根)
3. **Environment variables** (Settings → Environment variables):
   | Variable | Production | Preview |
   |---|---|---|
   | `SUPABASE_URL` | `https://xjvoqpijrpjmgqkqwhqd.supabase.co` | 同 |
   | `SUPABASE_ANON_KEY` | (Dashboard 设置, **不在 README 写**) | 同 |
4. 首次 push 后自动部署 → 域名 `https://fortune-master.pages.dev`

**方式 2（手动）**:

```bash
npm i -g wrangler
wrangler login
wrangler pages project create fortune-master --production-branch=main

flutter build web --release --no-tree-shake-icons \
  --dart-define=SUPABASE_URL=https://xjvoqpijrpjmgqkqwhqd.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon_key>

wrangler pages deploy build/web --project-name=fortune-master --branch=main
```

**关键文件**（已包含）：
- `_headers` —— 安全头部 (CSP / HSTS / X-Frame-Options / Permissions-Policy)
- `_redirects` —— `/privacy` `/terms` `/cookies` 301
- `wrangler.toml` —— Pages 项目配置

### B. Supabase Edge Functions（后端）

4 个函数: `chart-bazi`, `chart-tarot`, `chart-qimen`, `interpret` (2026-07-01 实装)

部署:

```bash
supabase login  # 首次
supabase link --project-ref xjvoqpijrpjmgqkqwhqd
supabase functions deploy chart-bazi
supabase functions deploy chart-tarot
supabase functions deploy chart-qimen
supabase functions deploy interpret
```

环境变量 (Supabase 端, 不是 Cloudflare 端):

```bash
supabase secrets set --project-ref xjvoqpijrpjmgqkqwhqd \
  FREELLMAPI_URL=http://localhost:3001/v1 \
  FREELLMAPI_KEY=<freellmapi_key> \
  IS_PUBLIC_RELEASE=false
```

**生产切换到 DeepSeek**: `supabase secrets unset FREELLMAPI_*` 然后 `supabase secrets set LLM_BASE_URL=https://api.deepseek.com/v1 LLM_API_KEY=<deepseek_key> IS_PUBLIC_RELEASE=true` — 业务代码 0 改动.

### C. 自检

部署后跑:

```bash
# 函数
curl -X POST "$SUPABASE_URL/functions/v1/chart-bazi" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"birthYear":1990,"birthMonth":5,"birthDay":15,"birthHour":14,"gender":"male"}'

# 解读 (需先设 LLM key)
curl -X POST "$SUPABASE_URL/functions/v1/interpret" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"system":"bazi","tier":"brief","locale":"en","chart":{"dayMaster":"Geng"}}'
```

## 📜 License

MIT — 详见 [LICENSE](LICENSE)

注：依赖的 `taibu-core` 同样是 MIT；其他 fork 仅作 reference，不直接复制代码（详见 `docs/plans/2026-07-01-fortune-master-design.md §2.7`）。
