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

## 📜 License

MIT — 详见 [LICENSE](LICENSE)

注：依赖的 `taibu-core` 同样是 MIT；其他 fork 仅作 reference，不直接复制代码（详见 `docs/plans/2026-07-01-fortune-master-design.md §2.7`）。
