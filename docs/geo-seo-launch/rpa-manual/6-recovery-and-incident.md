# 6 · 异常恢复 & 事件响应

> 当任意平台出现"账号警告 / 强制验证 / 内容被隐藏 / 流量腰斩"信号，所有 4 个平台必须**立即降级为保险模式**，先排查、再恢复。
> 本文档给 owner + AI 双方一台"事故处理清单"。

---

## 0 · 故障分级（4 级）

| 级别 | 名称 | 触发条件 | AI 立即动作 |
| --- | --- | --- | --- |
| **L0** | Heartbeat 异常 | 网络掉线 / playwright 卡死 | retry 1 次，重启 browser |
| **L1** | 平台软警告 | `unusual sign-in`、`posting too often`、AutoModerator 删除 | screenshot + `pause.json=true` + owner 邮件 |
| **L2** | 账号限制 | `account restricted`、`shadow ban`、发帖被自动折叠，reach < 1/3 通常值 | screenshot + **该账号 14 天冻结尾** + 等 owner 介入 |
| **L3** | 主账号被永封 | "Your account has been suspended permanently" | screenshot + **永久停用该账号** + owner 立刻人工申诉 |

---

## 1 · pause / resume 机制（核心）

> 所有 4 个平台**共享一个全局 pause 标志**。这是最后一根救命稻草。

```
~/geo-seo-rpa/state/pause.json
{
  "global": false,
  "per_platform": {
    "linkedin": false,
    "medium":   false,
    "quora":    false,
    "reddit":   false
  },
  "per_account": {
    "david-loan@linkedin.com": false,
    "david-loan@medium.com":   false,
    "u/david-loan-2026":       false,
    "david-loan@quora.com":    false
  },
  "set_by": "auto-detector@step5",
  "set_at": 1720036800,
  "reason": "AutoModerator removed post r-2026-07-10-loan",
  "expires_at": 0
}
```

### 1.1 Pause 的触发与解除

| 触发者 | 触发条件 | pause 范围 |
| --- | --- | --- |
| Playwright 抓屏检测到红条幅 | "unusual login" | `per_platform[platform]=true` |
| AutoModerator 删除率 ≥ 30%（昨日内） | 任何平台 | `per_platform[platform]=true` |
| 同一账号当日 catch limit 触发 | 24h guard 已 fail | `per_account[account]=true` |
| Owner 紧急停机键 | 物理开关（桌面脚本） | `global=true` |

### 1.2 Resume 的强制流程

```python
def resume(who, scope):
    """
    who: "owner" | "auto"
    scope: "global" | "platform" | "account"

    永不无人值守恢复。
    """
    if who == "auto":
        # auto 只允许：同一账号 24h 后 + pause 原因已解决
        if not is_remediated(scope):
            raise PermissionError("auto resume blocked; remediation pending")
    if who == "owner":
        # owner 必须输入 resume_token 二次确认
        tk = read_owner_resume_token(scope)
        assert tk and now() < tk.expires_at
        clear_pause(scope)
```

---

## 2 · 24h warning triggers（必须立即响应的检测信号）

### 2.1 LinkedIn

| 信号 | detection 路径 | 动作 |
| --- | --- | --- |
| 红条幅"unusual sign-in" | `page.locator("div:has-text('unusual sign-in')")` | screenshot → L1 pause platform |
| "You've been posting too often" | `page.locator("div:has-text('posting too often')")` | screenshot → L1 |
| 个人主页消失 | `GET /in/<slug>` 返回 404 | screenshot → L2 account |
| 强制 captcha | `iframe[src*='captcha']` | screenshot → L1 (手动过 captcha 后再恢复) |

### 2.2 Medium

| 信号 | detection 路径 | 动作 |
| --- | --- | --- |
| 草稿被自动 lock | 编辑器 disabled + tooltip "this draft has been locked" | L2 账号 14 天 |
| 文章 pending review | 文章页显示 "Pending review" banner | L1 platform 7 天 |
| "Your account is suspended" | `page.locator("text='Your account is suspended'")` | L3 永封 |

### 2.3 Quora

| 信号 | detection 路径 | 动作 |
| --- | --- | --- |
| 回答被折叠 | 回答页面右下显示"collapsed" | L1 platform |
| "Your account has been restricted" | 顶部红色条幅 | L3 永封 |
| View 数爆减 | 当新回答 6h 后 views < 5 | L1（可能触发 shadow filter） |

### 2.4 Reddit

| 信号 | detection 路径 | 动作 |
| --- | --- | --- |
| AutoModerator 删除 | 帖子下方出现 "[removed]" | L1 platform 24h |
| shadow ban | `GET /user/{name}/submitted` 返回空 | **L3**；shadow ban 不可逆，从 owner 看 |
| Sub ban | 提交时收到 "you are banned from posting to this community" | L2 account |

---

## 3 · 降温策略（cool-down protocol）

> 出现 L1 / L2 后必须执行的"被动消毒"。

### 3.1 LinkedIn 14 天降温

```
Day 0   : pause + owner 人工
Day 1-3 : 0 动作
Day 4-7 : 每 2 天去一次 feed 浏览（read-only，不点 like/不点 comment、不点任何 upvote）
Day 8-13: 每 1.5 天发 1 条 80–120 字个人短文，无外链、无 #、无 CTA
Day 14  : 重新进入 publish 阶段
```

### 3.2 Medium 7 天降温

```
Day 0-3 : 不发、不编辑、不读 notification
Day 4-6 : 读他人文章 + 用 "Clap" 50 次以下（不是强行 share）
Day 7   : 解冻
```

### 3.3 Quora 7 天降温

```
Day 0-3 : 0 动作
Day 4-6 : 在已有问题上 reply 1 条/账号（非评论别人的回答，而是给同问题一个新答案）
Day 7   : 解冻
```

### 3.4 Reddit 30 天降温

```
Day 0-7 : 完全静默，不访问
Day 8-21: browser-only upvote/feed 浏览
Day 22+: 重新进 publisher 阶段
```

---

## 4 · 申诉模板（platform-appeal）

> owner 手工用，但 AI 可以**生成模板初稿**。

### 4.1 LinkedIn 永封申诉

> 给 appeals@linkedin.com 的英文模板

```
Subject: Re: Account Review Request — {account_name}

To LinkedIn Trust & Safety,

I'm writing to request a review of the suspension of my account
{account_name} (account email: {email}). I'm an independent real-estate
advisor based in California and use LinkedIn to share professional
insights related to my industry.

On {date} I attempted to publish {n} posts in {duration}. I understand
that this may have triggered your automated anti-spam systems.

I'd respectfully request a manual review of my account activity:

1. All articles posted are original content reflecting my own professional
   experience. Examples: {url1}, {url2}, {url3}.
2. I do not engage in mass messaging or automated connection requests.
3. My account is in good standing with respect to your
   Professional Community Policies.

If you would like to verify my identity, I am happy to provide a
government-issued ID. Please contact me at {owner_email} or {phone}.

Thank you for your time.

Best,
{owner_name}
{owner_address}
```

### 4.2 Medium 草稿锁定申诉

```
Subject: My draft was auto-locked — appeal

To Medium Support,

My recent draft "..." was placed under auto-lock. I'm an
independent writer and can confirm:

1. All text is my original work.
2. The article does not contain harmful or restricted content.
3. I haven't used any third-party publishing tools.

Could a human please review the draft and unlock it if appropriate?

Thanks,
{owner_name}
```

### 4.3 Reddit shadow ban 申诉

> 注意：Reddit **明确不回应** shadow ban 申诉，只能**预防**。
> 当 shadow ban 触发，唯一恢复路径是：`register_new account + abandon old`。

### 4.4 Quora 账号限制申诉

```
To: appeals@quora.com

Subject: Account restriction review — {account_name}

Hello,

My account {account_name} appears to be restricted. I've been a
contributor on Quora for {weeks} weeks, focused on {topic}.
All my recent answers are based on first-hand experience.

Could you please review the restriction and let me know what
specific content triggered it? I'd like to correct any violations.

Thank you,
{owner_name}
```

---

## 5 · 备份与恢复（disaster-proof）

> 即使 4 个平台**全部被永封**，我们的资产（3 个主站点 + Medium publications + LinkedIn reposts）都还能继续发布。

### 5.1 资产清单（永久备份）

```
~/geo-seo-rpa/state/BACKUP/
├── content-source-md/        # 原始 markdown，永远不要再碰
├── screenshots/              # 发布成功的所有截图
├── content-status.json       # 已发布 URL 列表
├── storage-states/           # 每个账号 session token（**加密**）
└── contacts.md               # 各平台的申诉邮箱 / 表单 URL
```

### 5.2 全平台永封的 24 小时响应

| 时点 | 动作 |
| --- | --- |
| 0h | `pause.json=global`；保留所有截图与日志 |
| 4h | owner 召集会议，决定是否恢复 SEO/GEO 主线 |
| 8h | 启动 **recovery plan**：新注册一批账号（不同 IP、不同邮箱、不同 fingerprint），重新跑文件 2 静默期 14 天 |
| 24h | 在 3 个站点上把已发布内容永久化，外部依赖降到只剩 RSS / 邮件订阅 |

---

## 6 · 数据永久备份 SOP

- **每周日 02:00 PT** 自动执行 `tar.gz`：
  ```
  tar -czf backup-{date}.tar.gz \
      ~/geo-seo-rpa/state/ \
      ~/geo-seo-rpa/content/ \
      ~/geo-seo-rpa/screenshots/
  ```
- **保留**：本地一份 + 上传到 owner 私有的 Google Drive 一份（**绝不**传到公网云）
- **留存周期**：12 周滚动

---

## 7 · 操作审计（audit ledger）

> 一切 AI 行为都进 JSONL，便于事后追责。

```
~/geo-seo-rpa/logs/{YYYY-MM-DD}.jsonl
每一行的 schema：
{
  "ts": 1720036800,
  "platform": "reddit",
  "account": "u/david-loan-2026",
  "action": "publish_post",
  "post_url": "...",
  "input_hashes": {
    "draft_md_sha256": "...",
    "fingerprint_sha256": "..."
  },
  "outcome": "ok",
  "warnings": [],
  "screenshots": ["..."]
}
```

每周自动生成 `audit-weekly-{week}.md`，列：
- 当周 AI 发了几条
- 暂停/恢复了几个账号
- 遇到了几次 warning，怎么处理的
- owner 介入次数

---

## 8 · 4 个平台的"绝不再犯"红线

为了方便 owner 记忆，**最终红线 12 条**（来自 `0-overview.md` §12-ironclad-rules，但这里给具体触发场景）：

1. ❌ 同一 IP 同日跨 4 平台（高风险 IP 信号）
2. ❌ 同一账号 24h 内 ≥ 2 帖（自动弱化）
3. ❌ 同一 sub 24h 内 ≥ 2 帖（AutoModerator 删）
4. ❌ 外链未走 dry-run（Reddit）
5. ❌ 同时登录 2 个 LinkedIn context
6. ❌ 取代 owner 在 LinkedIn 手动 pin
7. ❌ 在 disabled browser 上强行 retry
8. ❌ 把 owner 真名写入内容正文（任何平台）
9. ❌ 公有云上传 state 文件
10. ❌ 跳过 pause 标志直接 publish
11. ❌ 对文章 / 回复进行 AI 风格的"duplicate"（无 paraphrase）
12. ❌ 在 owner 不知情的情况下主动联系任何陌生用户

每破一条 = 当周停发 + owner 复盘。

---

## 9 · 终极：长期可逆性

> owner 在任意时刻需要"回到完全干净状态"的话：

```bash
# 关掉一切
bash ~/geo-seo-rpa/tools/stop-all.sh

# 把 memory/credentials 加密备份
bash ~/geo-seo-rpa/tools/encrypt-and-archive.sh

# 抹掉本地所有 state
rm -rf ~/geo-seo-rpa/state/

# 仅保留 3 个站点 + 已发布文章的本地 markdown 档案
# 此后 AI 完全重启 = 走文件 2 bootstrap，可保留现有平台账号
#         也可重置账号 = 走文件 6 §5.2 24h disaster response
```

预期 restore 时间：单人手工 2 小时；带一份全新平台账号 24 小时。

---

## 10 · 不允许 AI 做的事（final & rigid）

- ❌ 关闭 `pause.json` 而 owner 没签 resume token
- ❌ 替 owner 写申诉邮件（生成模板可以，但 owner 必须 100% 自定）
- ❌ 跨平台同时操作
- ❌ 在 owner 电脑失联时强行继续
- ❌ 修改 `BACKUP/` 内容
- ❌ 把 audit ledger 删行
- ❌ 把任何账号尝试解封硬闯（即"用同样的 storage 再 login 试试")
- ❌ 任何被标 L3 的永封账号 30 天内再次访问

---

## 11 · 完成的判定

事件闭环必须满足：

1. ✅ `pause.json` 状态恢复成 `{global:false}` 或已确认永久 弃用某账号
2. ✅ 对应账号的 `last-action-at.json` 已记录最终时间戳
3. ✅ `audit-weekly-{week}.md` 里出现一份 incident 报告
4. ✅ owner 已签字同意 resume（一次"owner-resume-tk"已存证）
5. ✅ owner 必要时已发出 resume 命令，AI 不擅自恢复

满足以上 → 该事件关闭；下周重新进入文件 3/4/5 的常规 publish 循环。
