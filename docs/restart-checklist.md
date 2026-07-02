# 重启启动清单 — Windows 重启后 10 分钟推进指南

> 创建时间: 2026-07-01
> 适用场景: 重启 Windows 后继续推进 Fortune Master Phase 1
> 预计耗时: 首次 25-35 分钟（含 Flutter SDK 下载），后续每次 5 分钟

---

## 🎯 目标

重启后第一件事：让本地环境跑通"Flutter Web 看到 8 个占卜模块入口"，并把 chart-bazi / chart-tarot 两个 Edge Function 部署到 Supabase 云端验证。

完成 ✅ 的标志：
- `flutter run -d chrome` 浏览器看到双语首页 + 8 个模块入口
- Supabase Edge Function `chart-bazi` 用 curl 能返回 BaziResponse JSON
- taibu-core 奇门 bug 在 Deno 环境是否复现已确定

---

## ⏱️ 时间分配

| 阶段 | 任务 | 预计时间 |
|------|------|----------|
| 阶段 1 | 重启 + 环境验证 | 3 分钟 |
| 阶段 2 | 安装 Flutter SDK | 15-20 分钟（一次性） |
| 阶段 3 | 安装 Supabase CLI + Deno | 5 分钟 |
| 阶段 4 | Flutter 项目验证 | 3 分钟 |
| 阶段 5 | Supabase 云端部署 | 5 分钟 |
| 阶段 6 | Edge Function 验证 | 3 分钟 |
| **合计** | | **35-40 分钟（首次）** |

---

## 阶段 1：重启 + 环境验证（3 分钟）

### 1.1 重启 Windows

设置 → 系统 → 恢复 → 高级启动 → 立即重启
（或在 cmd 跑 `shutdown /r /t 0`）

### 1.2 重启后验证文件锁已清除

打开 PowerShell 跑：

```powershell
# 验证旧的 flutter.zip 残留
Test-Path C:\Users\david\Downloads\flutter.zip
# 期望: False（如果 True，先手动删掉）

# 验证 Docker Desktop 已激活
docker --version
# 期望: Docker version 24.x 或更高
```

如果 Docker 还报 "Docker Desktop is not running"，手动从开始菜单启动一次。

---

## 阶段 2：安装 Flutter SDK（15-20 分钟，一次性）

### 2.1 下载（这次用稳定通道）

```powershell
# 切到下载目录
cd C:\Users\david\Downloads

# 用 curl 下载（约 800MB，给足 timeout）
curl -L -o flutter.zip "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip" --max-time 1800
```

如果还卡，备选：浏览器手动下 https://docs.flutter.dev/get-started/install/windows 里的 stable channel zip。

### 2.2 解压到 C:\

```powershell
# 用 PowerShell 的 Expand-Archive（不要用第三方解压工具，可能 NTFS 权限错）
Expand-Archive -Path C:\Users\david\Downloads\flutter.zip -DestinationPath C:\ -Force

# 验证
Test-Path C:\flutter\bin\flutter.bat
# 期望: True
```

### 2.3 加入 PATH

```powershell
# 用户级 PATH（永久）
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\flutter\bin",
    "User"
)

# 重开 PowerShell 让 PATH 生效
```

### 2.4 验证 Flutter 安装

```powershell
flutter --version
# 期望看到 3.24.x 版本

flutter doctor
# 期望: Flutter ✅, Chrome ✅, Android toolchain (略过), VS Code ✅
```

如果 `flutter doctor` 报 "Visual Studio not installed"：可暂时忽略（开发 Flutter Web 不需要）。报 "Android licenses not accepted"：也忽略。

---

## 阶段 3：安装 Supabase CLI + Deno（5 分钟）

### 3.1 Supabase CLI（Node 包）

```powershell
npm install -g supabase
supabase --version
# 期望: 1.180+ 或更新
```

### 3.2 Deno 运行时（Edge Functions 需要）

```powershell
# PowerShell 一行安装
irm https://deno.land/install.ps1 | iex

# 重开 shell 后验证
deno --version
# 期望: deno 1.45+
```

### 3.3 登录 Supabase

```powershell
supabase login
# 会弹出浏览器授权，授权后回到 shell
```

---

## 阶段 4：Flutter 项目验证（3 分钟）

```powershell
cd C:\Users\david\ZCodeProject

# 拉依赖（首次 1-2 分钟）
flutter pub get

# 生成 l10n（ARB → Dart）
flutter gen-l10n
# 期望: Generated 49 message(s) in app_en.arb, app_zh.arb

# 跑起来！默认会用 Chrome
flutter run -d chrome
```

浏览器应自动打开 http://localhost:3000 或类似端口，看到：
- 顶部标题："Fortune Master · 中西算命大全"
- 8 张渐变卡片（Bazi / Ziwei / I Ching / Tarot / Astrology / Face / Dream / Community）
- 右上角语言切换按钮（EN / 中）

看到 ✅ 就按 `q` 退出，准备进阶段 5。

如果 `flutter gen-l10n` 报错：
- 检查 `l10n.yaml` 是否在项目根（已存在）
- 检查 `flutter:` 段在 `pubspec.yaml` 是否写了 `generate: true`（已存在）
- 重跑一次 `flutter pub get`

---

## 阶段 5：Supabase 云端部署（5 分钟）

### 5.1 创建云项目（浏览器手动）

1. 打开 https://supabase.com/dashboard
2. 点 "New Project"
3. 名称：`fortune-master-dev`
4. 数据库密码：设一个强密码，存到密码管理器
5. Region：`Singapore`（亚洲最近，离中国大陆近）
6. Plan：`Free`（够 Phase 1 用）
7. 等 1-2 分钟项目初始化完成

### 5.2 链接本地项目

记下项目的 **Project Ref**（在 Settings → General 里，形如 `abcdefghij`），然后：

```powershell
cd C:\Users\david\ZCodeProject
supabase link --project-ref <你的-project-ref>
# 会提示输入数据库密码
```

### 5.3 跑 SQL 迁移

```powershell
supabase db push
# 期望: Applying migration 20260701000001_init_schema.sql... ✅
```

### 5.4 部署 Edge Functions

```powershell
supabase functions deploy chart-bazi
supabase functions deploy chart-tarot
```

部署成功后，Supabase Dashboard → Edge Functions 应能看到两个函数。

---

## 阶段 6：Edge Function 验证（3 分钟）

### 6.1 验证 chart-bazi

```powershell
# 从 Supabase Dashboard → Settings → API 复制 anon key
$ANON_KEY = "eyJhbGc..."

curl -X POST `
  "https://<project-ref>.supabase.co/functions/v1/chart-bazi" `
  -H "Authorization: Bearer $ANON_KEY" `
  -H "Content-Type: application/json" `
  -d '{
    "name": "张三",
    "gender": "male",
    "birthDate": "1990-05-15",
    "birthTime": "14:30",
    "birthLat": 39.9042,
    "birthLng": 116.4074,
    "birthTimezone": "Asia/Shanghai"
  }'
```

期望返回：
```json
{
  "chart": {
    "yearPillar": {"heavenly": "庚", "earthly": "午"},
    ...
  },
  "system": "bazi",
  "lang": "zh-CN"
}
```

### 6.2 验证 chart-tarot

```powershell
curl -X POST `
  "https://<project-ref>.supabase.co/functions/v1/chart-tarot" `
  -H "Authorization: Bearer $ANON_KEY" `
  -H "Content-Type: application/json" `
  -d '{"spread": "one", "lang": "zh-CN"}'
```

期望返回 3 张随机塔罗牌（含 positionLabels 中文）。

### 6.3 验证奇门（关键 Bug 验证）

```powershell
curl -X POST `
  "https://<project-ref>.supabase.co/functions/v1/chart-qimen" `
  -H "Authorization: Bearer $ANON_KEY" `
  -H "Content-Type: application/json" `
  -d '{
    "datetime": "2026-07-01T14:30:00+08:00",
    "lang": "zh-CN"
  }'
```

**三种可能结果**：
| 结果 | 含义 | 下一步 |
|------|------|--------|
| 返回完整奇门盘 | Deno 环境无 bug，Node 24 特有 | 在 incident 报告里更新 ✅ 解决 |
| 返回 `{}` 同 Node | 跨运行时 bug，需要 wrapper | 实施"Workaround 1"：手动 +8 小时 timezone 偏移再调用 |
| 报错 / 5xx | Deno 不兼容 ESM | 切到 tarball 方式（Workaround 3） |

验证完后打开 `docs/incidents/2026-07-01-taibu-core-qimen-empty.md` 把结果追加进去。

---

## 🎉 全部 ✅ 后

Phase 1 Week 3 完成度评估：

- ✅ Flutter Web 本地可跑
- ✅ Supabase Postgres schema 上线
- ✅ 2 个 Edge Function 部署 + 验证
- ✅ 奇门 bug 在 Deno 环境验证完毕（无论结果如何都有结论）

下一步进入 Week 4（Flutter 登录 + 首页绑定真实数据），可以继续推进或休息。

---

## 🆘 卡住时

| 现象 | 排查 |
|------|------|
| `flutter doctor` 报 VS 缺失 | 忽略，Web 不需要 |
| `supabase link` 失败 | 检查 ref 没复制错；检查网络能访问 supabase.com |
| `supabase functions deploy` 失败 | 检查 deno 已装；`supabase --version` >= 1.180 |
| `flutter run -d chrome` 白屏 | `flutter clean && flutter pub get && flutter run -d chrome` |
| `chart-bazi` 报 401 | anon key 没复制对；重新从 Dashboard 复制 |
| `chart-bazi` 报 500 | 看 `supabase functions logs chart-bazi` |
| curl 返回 HTML | URL 末尾漏了函数名；或 project-ref 错了 |

---

## 📋 完成确认

跑通后跟我说"✅ 全跑通了"或贴最后一条 curl 的输出，我接着推 Week 4。

如果某一步卡住，直接贴错误信息 + 跑过的命令，我帮你诊断。