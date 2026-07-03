# 5 · Quora & Reddit 发布剧本（养号过渡 → 周节奏：6 条回答 + 3 条帖子）

> 本剧本是 W3-W4 的"养号过渡 + 真实发布"组合：
> - **W1-W2**：纯养号阶段（已在 `2-account-bootstrap.md §daily-silent-phase` 完成，本文件不重复）。Reddit 14 天内只允许 upvote，不能 publish。
> - **W3+**：进入真实发布——Quora 6 条/周（每账号 2 条），Reddit 3 条/周（每账号 1 条主帖）。
>
> 与文件 3/4 不同的是：Quora / Reddit 是**强社区**环境，这意味着我们需要：
> - **问题/子版选股**（避免高竞争问题）
> - **标签 / Flair**（Reddit 强约束）
> - **AutoModerator 规则触发识别**
> - **Vote-target manipulation 防护**（不要让 upvote/reply 节奏异常）

---

## Part A · Quora

### A.0 · Quora 特殊性

| 项 | 平台规则 / 我们的对策 |
| --- | --- |
| Quora 单账号回复上限 | 实测单账号 24h 超过 4–5 条回答，reach 腰斩；→ 每账号每周 ≤ 2 条 |
| 回答 vs 评论 | 评论别人问题的内容**对 SEO 权重远低**于回答；只在问题上"Add Answer"**才**算 GEO 显式资产 |
| Spaces | 把回答挂到 Space 下，能让同一账号聚合特定行业权重 |
| 外链策略 | 正文内只放 1 个外链，放文章中段；结论段"以上是我工作时整理的笔记，**完整版见个人博客**"，把知乎读者引导回 3 个站点 |
| Bot Detection | Quora 对 Puppeteer 的检测弱于 LinkedIn，但仍对"连续编辑 / 全键盘 type"敏感；本剧本**全程用 clipboard paste + evaluate** |
| 答案被折叠 | 长度过短 / 外链过多 / 早期 downvote 触发的折叠；提前用 `preflight` 检查 |
| 匿名模式 | Quora 现已部分关停匿名问/匿名答，所有回答必须挂在 1 个账号 |

---

### A.1 · 账号 ↔ 主题映射

| 账号 | 主 Space | 主答话题 |
| --- | --- | --- |
| `david-loan@quora.com` | "DSCR Loan Insights" | California real-estate investing / mortgage product |
| `david-rent@quora.com` | "California Landlord Essentials" | Tenant rights / eviction / habitability / AB-1482 |
| `david-buddha@quora.com` | "海外华人佛学参考" | 中文佛教、祖先、在线佛事、中华丧葬文化 |

每个账号在 `~/geo-seo-rpa/state/quora/<account>/` 下有：

```
├── storage.json          # 含 session.id cookie；用 owner 提供的 token / password 引导
├── fingerprint.json
├── last-answer.json
└── blocked-topics.json   # 不回答的话题列表（避免触发 Quora "敏感"自动弱化）
```

---

### A.2 · 选股（question selection）· 关键

> 不能随便答。Quora 算法把"高展示、低回答数"问题加权。

```python
def find_target_question(site):
    """从本周预筛 4 个候选问题中选 1 个最优"""
    candidates = fetch_weekly_candidates(site)   # 文件 9-publishing/cta-prompts-templates.md §Question sourcing
    # 排序依据
    score = lambda q: q["weekly_views"] / max(q["answer_count"], 1) * (
        # 还要看最近 1 周是否被新回答刷过
        1.5 if not q["hot_recently"] else 0.4
    )
    candidates.sort(key=score, reverse=True)
    return candidates[0]
```

> **铁律**：避开 `view_count < 1,000`（拼多多级别问题，没人看）和 `view_count > 500,000, answer_count > 80`（竞争惨烈，新回答永远排末尾）的两个极端。

---

### A.3 · 回答长度 / 结构模板

| 段落 | 字数 | 内容 |
| --- | --- | --- |
| Hook | 50–80 | 共情或反共识开场（"上周我处理了一个客户……"） |
| Body 1 | 250–400 | 详述一：可视化 / 数字 / 案例 |
| Body 2 | 250–400 | 详述二：法律依据 / 数据 / 反例 |
| "How we help" 段落 | 150–200 | 中间放外链（**仅 1 个**），引入原文 URL |
| Closing | 80–120 | 留问句，刺激读者互评 |
| 总长 | 800–1300 | 太长读不下去，太短进折叠区 |

---

### A.4 · Step-by-step（每个回答）

#### Step 1：kick-off + 24h guard

```python
token = ensure_kickoff(action="publish-quora")
for acc in ["david-loan", "david-rent", "david-buddha"]:
    assert ok_to_answer(acc), f"24h guard tripped on {acc}"
```

#### Step 2：每个账号挑 2 个问题

```python
for acc in ACCOUNTS:
    q1 = find_target_question(acc.site)
    q2 = find_target_question(acc.site, exclude=q1)
    plan[acc] = [q1, q2]
assert sum(len(v) for v in plan.values()) == 6
```

#### Step 3：预写 + 离线 lint

```python
import re
from pathlib import Path

for q_key, q in load_questions():
    draft = Path(f"~/geo-seo-rpa/content/this-week/quora/{q_key}.md").read_text(encoding="utf-8")
    # 长度
    assert 800 <= len(draft.split()) <= 1300, f"len out of range on {q_key}"
    # 外链数（**只允许 1 个**）
    links = re.findall(r"https?://[^\s)]+", draft)
    assert len(links) == 1, f"external link must be exactly 1 in {q_key}, got {len(links)}"
    # 外链必须指向对应 site
    assert SITE_DOMAIN[q.site] in links[0], "external link domain mismatch"
    # 没有 clickbait / AI-suspicious 词
    title_lint(draft)
```

#### Step 4：浏览器 + storage_state（**每个回答独立 context，独立开关**）

```python
ctx = browser.new_context(
    storage_state=f"~/geo-seo-rpa/state/quora/{account}/storage.json",
    **fingerprint_for(account)
)
page = ctx.new_page()
page.goto(q["url"], wait_until="domcontentloaded")
```

#### Step 5：写答案

```python
page.locator("div[contenteditable='true']").first.click()  # 找到 Answer 编辑器
# 全文通过剪贴板粘贴：clipboard.writeText 不是 Playwright 默认支持，要靠 page.context.grant_permissions
ctx.grant_permissions(["clipboard-read", "clipboard-write"])
page.evaluate(f"navigator.clipboard.writeText({json.dumps(draft)})")
page.keyboard.press("Control+V")
page.wait_for_timeout(random.randint(8_000, 14_000))    # 模拟打字间停顿
shot("step5-quora-pasted.png", page)
```

> **铁律**：不能用 `page.keyboard.type` 一字一字打，Quora 会通过 `keypress events` 分布标记机器人。

#### Step 6：发送并等待渲染

```python
page.locator("button:has-text('Post')").last.click()
page.wait_for_url(re.compile(r"/answers/"), timeout=20000)
shot("step6-quora-posted.png", page)
```

#### Step 7：状态写入 + guard 更新

```python
append_status({
    "id": f"q-{date.today().isoformat()}-{account_site}",
    "platform": "quora",
    "account": account,
    "question_id": q["id"],
    "question_url": page.url,
    "external_link": extract_external_link(draft),
    "publish_ts": int(time.time()),
    "kickoff_token": token,
})
update_last_answer(account, next_allowed=int(time.time()) + 24 * 3600)
```

#### Step 8：关闭 context，等下条

```python
ctx.close()
sleep_random_mins(50, 110)  # 留够冷却时间
```

---

### A.5 · Quora 反检测

| 检查 | 通过条件 |
| --- | --- |
| 单账号 24h 回答数 | ≤ 2 |
| 外链数量 | 每答案 exactly 1 |
| 字数 | 800–1300 |
| 拼接 vs 改写 | 必须**至少 30% 与原始 markdown 不同**（owner 可以让 AI 改写，但发布前的最终稿需 owner 签字） |
| 选中的问题来源 | 至少有 1 条"近 30 天新增 / 24h 内 50+ view"，新增回答填进来 |
| 自动 upvote 自己 answer | **禁止**。Quora 会因此 fold |

---

### A.6 · Quora 不允许 AI 做的事

- ❌ upvote / downvote 任何人
- ❌ Comment 在别人回答下方
- ❌ 提出新问题
- ❌ follow / unfollow 用户
- ❌ 发问题悬赏
- ❌ 复制其他用户回答改一字再发
- ❌ 在用户头像下私信
- ❌ 将 owner 的真实姓名/邮箱/电话放到任何回答正文

---

## Part B · Reddit

### B.0 · Reddit 平台特殊性 · 必读

> Reddit 是 **4 个平台中最容易永久封号**的——AutoModerator 是按规则机械执行的，shadow ban 非常快。

| 项 | 平台规则 / 我们的对策 |
| --- | --- |
| Subreddit 选股 | 不是所有 sub 都能发。我们列 12 个"首选 sub"：r/realestateinvesting、r/landlord、r/CaliforniaLandlords、r/Buddhism、r/ChineseLanguage 等 |
| Karma 阈值 | 很多子版要求 `comment karma > 50`、账号 `age > 14 days`。W1-W2 强制 silent phase 让账号养足 age 与 karma |
| AutoModerator 关键词 | `mortgage broker`、`rates today`、`click my link`、`DM me` 等词会被删除或 shadowban |
| Subreddit 标签规则 | r/realestate 的 [Broker-Dealer] 等强制 tag 必须命中 |
| 24h 发帖上限 | Reddit 不会明文设限，但**同一 sub 内每 24h 1 帖是上限**，跨 sub 多发也易触发"spam domain" |
| 域名 | 外链到非主流域（如 loaninca.com）会被 AutoModerator `domain not whitelisted` 删除——**所以 W3 前先把域名提交到 r/realestateinvesting 等 sub 的 whitelist** |
| Vote | AI **绝不可**对任何帖子 upvote/downvote——即使是自己发的（reddit 会查 IP 群） |

---

### B.1 · 账号映射

| 账号 | 默认 sub 标签 | 主题 |
| --- | --- | --- |
| `u/david-loan-2026` | `Investor` | loaninca 内容 |
| `u/david-rent-2026` | `CA Landlord` | rentalinca 内容 |
| `u/david-buddha-2026` | `OC community` | fopusha 内容 |

> 用户名末尾 `-2026` 是为**防止外人在公开搜索中找到真人 David Liu**。

---

### B.2 · W1-W2 养号 → 状态机过渡

```
W1  Day 1: silent phase script 加载（仅 upvote + watch）
W1  Day 7: 开始 active karma gain
W2  Day 14: 进入 W3 publish 剧本
```

| 阶段 | 时长 | 允许动作 | 不允许动作 |
| --- | --- | --- | --- |
| silent | D1-D3 | 浏览、看 trending | 评论、发帖、upvote |
| casual | D4-D7 | 偶尔 upvote | 评论、发帖 |
| contributor | D8-D13 | 评论（≤ 1 条/24h）、少量 upvote | 发帖 |
| publisher | D14+ | 1 帖/账号/24h + 评论（≤ 4 条/24h） | 同一 sub 1 帖/24h |

> 进入 publisher 阶段的判定：`u/<account>` 的 `comment_karma >= 50 && account_age >= 14 days`。脚本每天自动跑一次查 karma（文件 1 §utils.get_karma）。

---

### B.3 · Find target subreddit

```python
SUB_WHITELIST = {
    "loaninca":   ["realestateinvesting", "realestate", "personalfinance"],
    "rentalinca": ["landlord", "CaliforniaLandlords", "RealEstate"],
    "fopusha":    ["Buddhism", "ChineseLanguage", "expats"],
}

def pick_sub(site, accounts):
    candidates = []
    for sub in SUB_WHITELIST[site]:
        rules = fetch_sidebar_rules(f"https://www.reddit.com/r/{sub}/about/rules")
        rule_ok = check_posting_allowed(rules, our_account)
        recent = fetch_recent_post_density(f"https://www.reddit.com/r/{sub}/new")
        candidates.append((sub, rule_ok, recent))
    return max(candidates, key=lambda x: (x[1], -x[2]))
```

#### B.3.1 AutoModerator dry-run

```python
def dry_run_sub(text, sub):
    """根据 sub sidebar rules 对 text 模拟 AM 删除原因"""
    rules = load_sidebar_rules(sub)
    flags = []
    for kw in rules.get("remove_keywords", []):
        if kw.lower() in text.lower():
            flags.append(("remove_keyword", kw))
    if count_links(text) > rules.get("max_links", 2):
        flags.append(("too_many_links", count_links(text)))
    if rules.get("flair_required") and not detect_flair_in_text(text):
        flags.append(("missing_flaw", ""))
    if contains_phone_number(text):
        flags.append(("phone_number_present", ""))
    return flags

# 在 post 之前 dry-run 一次
fl = dry_run_sub(post_body, target_sub)
assert not fl, f"AutoModerator flags for {target_sub}: {fl}"
```

> **铁律**：dry-run 不通过，**绝不提交**。

---

### B.4 · Step-by-step（每个 Reddit post）

#### Step 1：kick-off + 平台 guard

```python
token = ensure_kickoff(action="publish-reddit")
for acc in REDDIT_ACCOUNTS:
    st = read_state(acc)
    assert st["account_age_days"] >= 14, f"{acc} too young"
    assert st["comment_karma"] >= 50,   f"{acc} karma too low"
    assert not st["last_post_within_24h"], f"{acc} recent post"
```

#### Step 2：load draft (markdown already anti-AI style)

```python
draft = Path(f"~/geo-seo-rpa/content/this-week/reddit/{site}.md").read_text(encoding="utf-8")
# 来自 docs/geo-seo-launch/04-reddit/reddit-posts.md 里的"真人化"版本
# 必须已是首人口吻、含具体数字、含情绪时刻
```

#### Step 3：dry-run AutoModerator（见 B.3.1）

#### Step 4：浏览器 + storage_state（**reddit context 仅开 1 个**）

```python
ctx = browser.new_context(
    storage_state=f"~/geo-seo-rpa/state/reddit/{account}/storage.json",
    **fingerprint_for(account),
    user_agent="Mozilla/5.0 ...reddit-aware-UA..."
)
page = ctx.new_page()
```

#### Step 5：进到目标 sub

```python
page.goto(f"https://www.reddit.com/r/{sub}/submit", wait_until="domcontentloaded")
shot("step5-submit.png", page)
```

#### Step 6：选择发文本帖（Text post）

```python
page.locator("button:has-text('Text')").first.click()
page.wait_for_selector("div[contenteditable='true']")
```

#### Step 7：填 title → body

```python
page.locator("textarea[name='title']").fill(post_title)
ctx.grant_permissions(["clipboard-read", "clipboard-write"])
page.evaluate(f"navigator.clipboard.writeText({json.dumps(post_body)})")
page.locator("div[contenteditable='true']").click()
page.keyboard.press("Control+V")
page.wait_for_timeout(random.randint(8_000, 14_000))
shot("step7-filled.png", page)
```

> **铁律**：title 与 body 必须**有 50 字符以上差异**，否则 AM 标"重发"。

#### Step 8：选 Flair

```python
flairs = page.locator("div.flair-selector span").all_text_contents()
# 必须挑出我们在 sidebar-rules 里 dry-run 通过的那个
required = load_required_flairs(sub)
chosen = pick_first(flairs, lambda f: f.lower() in [r.lower() for r in required])
page.locator(f"span:has-text('{chosen}')").first.click()
shot("step8-flair.png", page)
```

#### Step 9：提交

```python
page.locator("button[type='submit']:has-text('Post')").click()
page.wait_for_url(re.compile(r"/r/[^/]+/comments/"), timeout=20000)
shot("step9-posted.png", page)
```

#### Step 10：状态更新

```python
append_status({
    "id": f"r-{date.today().isoformat()}-{site}",
    "platform": "reddit",
    "account": account,
    "subreddit": sub,
    "post_url": page.url,
    "flair": chosen,
    "publish_ts": int(time.time()),
    "kickoff_token": token,
})
update_last_post(account, sub=sub)
```

---

### B.5 · 评论脚本（publisher 阶段）

```python
def daily_reddit_chit_chat(account, max_comments=4):
    actions = []
    feed = page.locator("div[data-test-id='post-content']")
    candidates = []
    for post in fetch_hot_posts(SUB_WHITELIST[account.site][:3], limit=30):
        if post["comments_count"] >= 5 and post["recently_active"]:
            candidates.append(post)
    random.shuffle(candidates)
    for c in candidates[:max_comments]:
        if c["id"] in already_replied_ids(account):
            continue
        reply = generate_conversational_reply(    # 必须基于原文做 paraphrase，AI 改写
            source_text=c["body"][:1500],
            persona=account.site,
        )
        if len(reply) < 80:
            continue
        # 写评论
        post_link = c["permalink"]
        page.goto(post_link)
        page.locator("div[contenteditable='true']").first.click()
        page.evaluate(f"navigator.clipboard.writeText({json.dumps(reply)})")
        page.keyboard.press("Control+V")
        page.wait_for_timeout(random.randint(5_000, 9_000))
        page.locator("button[type='submit']:has-text('Comment')").click()
        actions.append({"post": post_link, "reply": reply})
    return actions
```

> **铁律**：评论**不允许出现我们 3 个站点的链接**——会被 AM 标 promotion。

---

### B.6 · Reddit 反检测

| 风险 | 应对 |
| --- | --- |
| 同一 sub 1 帖/24h | `update_last_post` 已加 `sub` 维度 |
| shadow ban | 写完 30 分钟后立刻跑 `GET /user/me/posts`；如果返回 403 → shadow ban，**立刻中止全部动作**，走文件 6 |
| AutoModerator delete | dry-run 已做；若仍被删，下次降低商业成分、改用 first-person narrative only |
| Domain not whitelisted | W2 末向目标 sub 提交 our-domain whitelist request（owner 人工做） |

---

### B.7 · Reddit 不允许 AI 做的事

- ❌ upvote / downvote（包括自己、其他任何帖）
- ❌ 评论里放自己站点链接
- ❌ 发自己账户的 Promoted post / Ad
- ❌ 修改 sub 描述 / 申请成为 mod
- ❌ 在 DMs 里发任何内容（脚本根本不该进入 DM 视图）
- ❌ 触发 NSFW 标签
- ❌ 公开关联到 owner 个人身份（如"这是我家公司"）

---

## Part C · 联合行为规则（Quora + Reddit 共同）

1. **每天只启一个平台的 context**——不要同一天里 Quora + Reddit 跨平台切换
2. 每次 publish 之前**至少 40 分钟冷却**
3. 内容发布后**至少 6 小时不动作**（不要 publish 完又回自己回答下补充）
4. publish 流量外链只能指向对应站点（loaninca 文章 → loaninca.com），不能串
5. 中英文分离：`david-buddha` 全部发中文、`david-loan` 与 `david-rent` 全部英文，不混用

---

## Part D · 完成判定

- ✅ `content-status.json` 当周新增 6 条 `platform=quora` + 3 条 `platform=reddit`
- ✅ 3 个 Reddit 账号 `last-post.json` 的 per-sub guard 都 ≥ 24h
- ✅ 3 个 Quora 账号 `last-answer.json` 的 next_allowed ≥ 当前 ts + 24h
- ✅ 每个子版的 AutoModerator 日志 `rpa-logs/auto-mod-{date}.log` 无 `remove=true` 条目
- ✅ 没有触发 shadow ban（`rpa-logs/shadowban-check.json` 每日检查为空）
- ✅ 所有截图都按 `<platform>/<site>-<step>.png` 归档

全部通过 → 该周结束，下周循环。
