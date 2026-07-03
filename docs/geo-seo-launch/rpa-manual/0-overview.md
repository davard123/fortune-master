# 0. 全套 RPA 操作手册 - 总览

> **撰写日期**: 2026-07-02
> **目标读者**: 浏览器自动化 AI Agent（运行在 David Liu 授权账户环境下）
> **环境假设**: Playwright + Chromium, Linux/macOS, 12 个平台账号已 预注册/已注册

---

## 0.1 这套手册要解决什么

要把这 12 周的发布 / 互动 / 数据追踪流程,自动化到一个 AI agent 能按剧本执行。**不是写给人看的,也不是写给大型 LLM 看的,是写给可以模拟浏览器行为的 RPA Agent 看的**。

每个文档的格式:
- **状态机**:什么时候这个 step 该跑 / 不该跑
- **DOM 选择器**:精确到 `class="submission-viewer"` 这样的 CSS selector
- **回退策略**:retry、abort、alert 人
- **日志输出**:每一步都要输出 json line 给 `state/rpa.log`

## 0.2 6 个文档的依赖关系

```
0-overview (本文档)
    ├─ 1-rpa-framework.md ← 必读
    │   ├─ 2-account-bootstrap.md   ← W1 用
    │   ├─ 3-medium-publish.md     ← W2 起
    │   ├─ 4-linkedin-publish.md   ← W2 起
    │   ├─ 5-quora-reddit-publish  ← W3 起
    │   └─ 6-recovery-and-incident ← 出问题时必读
```

## 0.3 12 条铁律 (必须严格遵守)

1. **每个平台账号的新建后 14 天内 = 静默养号期**
   - 只允许:点赞、浏览、收藏、阅读
   - **禁止**:发主题帖、长帖、评论(评论可在第 8 天起)
   
2. **每个平台 24 小时最多 1 次"发表"动作**
   - 必须在本机状态文件 `state/quota.json` 中登记 timestamp
   
3. **每个平台 72 小时最多 2 次评论动作**
   - 评论需要间隔 ≥ 4 小时
   
4. **Reddit sub 必须 ≥ 14 天内不重复发**
   - 记录 `state/reddit-history.json`
   
5. **每次操作截图存档**
   - `screenshots/{date}/{platform}/{action}-{timestamp}.png`
   
6. **published / not-published 状态记录**
   - `state/content-status.json` 记录每篇文章发布状态
   
7. **禁止注册新账号**
   - 只能在 W0-W1 一次性 setup 完所有 12 账号
   
8. **禁止使用平台 API 替代浏览器操作**
   - 必须模拟 browser 行为(按键/点击/输入)
   
9. **禁止触碰 2FA / 验证码环节**
   - 触发到 OTP/2FA 立刻 pause,call human
   
10. **禁止做删除 / 申诉 / 资料修改**
    - 所有删除/申诉/修改 = 必须由人手动
    
11. **每次平台警告(邮箱收到)/ 主页 toast 提示 / 任何账号异常 = system pause 30 天**
    - 触发 `pause` = 停止所有自动化,直到 human reset
    
12. **输出每日 log**
    - `state/log/{date}.jsonl` 每个动作一行

## 0.4 决策状态机 (high-level)

```
                    ┌── AI 注册完 12 账号(W0-W1)
                    │
W0-W1: Bootstrap ───┤
                    └── Human 注入 session cookies
                          │
                          ▼
W1-W2: Silent Phase ─┐
  只读/点赞/收藏     │
  不评论/不发表      ├─→ 读取 state/quota.json
                     │   检查 published count
                     │   检查 rate limits
                     │   暂停 if pause flag = true
                     ▼
W3-W14: Active Phase ─┐
  评论/小动作 ────────│
  7-day 后允许主题帖  │
                     │  到了 rate limit 中止今天
                     │  发生警告:trigger pause 30 天
                     ▼
Content Publishing ──→ 写 state/content-status.json
                     → 截图存档
                     → log 写 jsonl
                     → 异步 GC old screenshots
```

## 0.5 文件系统结构

```
~/geo-seo-rpa/
├── state/
│   ├── quota.json              # 24h 限制
│   ├── quota-{platform}.json   # 每个平台单独 quota
│   ├── content-status.json     # 文章发布状态
│   ├── reddit-history.json     # Reddit sub post history
│   ├── linkedin-history.json   # LinkedIn post history
│   ├── pause.json              # 系统暂停标志
│   ├── warnings.json           # 平台警告清单
│   └── log/
│       └── 2026-07-02.jsonl    # 每日日志
├── screenshots/
│   └── 2026-07-02/
│       ├── linkedin/
│       ├── reddit/
│       └── medium/
├── config/
│   ├── accounts.json           # 12 账号 credentials
│   ├── browser-fingerprint.json # 每次启动新 instance
│   └── content-queue.json      # 待发布内容
└── tools/
    └── scripts/{platform}.js   # 每个平台一个执行器
```

## 0.6 启动顺序

```bash
$ cd ~/geo-seo-rpa
$ npm install playwright
$ node tools/setup-state.js          # 初始化所有 state 文件
$ node tools/launch-daemon.js         # 启动定时 daemon
$ tail -f state/log/$(date +%Y-%m-%d).jsonl  # 看实时 log
```

详细 see: `1-rpa-framework.md`
