# 4 · LinkedIn 发布剧本（每周 3 条长帖 · 评论互动 · 置顶评论）

> 本剧本接续 `2-account-bootstrap.md` 之后启动。LinkedIn 是 4 个平台中**封号最敏感**的，因此节奏、字数、引外链动作必须严格控制。
> 与 Medium 不同：LinkedIn 核心是**先发布 → 立即自评 1 条置顶讨论 → 24h 内回复全部评论**，而非 canonical / tag 优化。

---

## 0 · LinkedIn 平台特殊性 · 必读

| 项 | 平台规则 / 我们的对策 |
| --- | --- |
| LinkedIn 个人档案 1 个仅 1 个 | 我们的 3 个账号 = David Liu (loan)、David Liu (rent)、David Liu (buddha)。每个账号**只有一个 site 主题**。 |
| LinkedIn 单日发文数 | 实测：单人账号 24h 内**第 3 篇起 reach 减半**，第 4 篇起强制"被限流到职业网络"。→ **每账号每周只发 1 条**。 |
| 评论链接权重 | LinkedIn 把评论链接设为 `rel="nofollow ugc"`，但**置顶评论（作者挑选的）会被搜索引擎抓取**，这是我们放外链的关键位。 |
| 编辑器 | LinkedIn 的文本编辑器是 contenteditable，且包含 shadow DOM（"重构编辑器"），用普通 `fill` 不可行，必须 `evaluate` + `KeyboardEvent`。 |
| 长文 (Article) vs 短文 (Post) | LinkedIn 的 Article 是 LinkedIn 域名内的内容；本剧本只发 **Post**（普通动态），1,300 字以内。 |
| 标签 hashtag | 3–5 个最优，过多会被降权；用 #RealEstateInvestment / #CaliforniaLandlord / #Buddhism 等 |
| 时间窗口 | 研究表明 **周二、周三 8–10 a.m. PT** 发帖互动率最高；3 条错开 1 天发，每周节奏：周二 1 条、周三 1 条、周四 1 条。 |
| 自动检测 | LinkedIn 任何在 1 session 内多账号切换 / 多目标 URL 跳转都会出"unusual login attempt"。**每个账号全周期走独立 context，绝不混**。 |
| 评论字数上限 | 评论单条 ≤ 1250 字符；置顶评论 ≤ 1250 字符。 |

---

## 1 · 4.1 与 4.2 / 4.3 子任务分工

```
4-linkedin-publish.md
├── 4.1 每周 3 条长帖主发布（周二、周三、周四 08:00 PT）
├── 4.2 自评置顶评论（每篇发布后 8 分钟内）
└── 4.3 当周回复全部评论（spread 到周六前完成）
```

> **铁律**：4.1 / 4.2 / 4.3 三个动作必须**串行执行**，不要并发，否则触发"burst activity"风险高。

---

## 2 · 状态机（核心是 _pause_ 与 _unwind_）

```
          [kick-off token]                [shot + status update]
                 │                                  ▲
                 ▼                                  │
   ┌────── READY ────┐  check 24h guard  ┌───  POST_PUBLISH_OK ───┐
   │  load week's 3   │ ───────────────► │  sleep 8 min → step 4.2  │
   │  posts md files  │                  │  ↓                        │
   └─────────────────┘                  │  load pinned comment       │
                                        │  write → screenshot        │
                                        │  ↓                        │
                                        │  UPDATE status.json        │
                                        │  ↓                        │
                                        │  [周六统一执行 step 4.3]   │
                                        └───────────────────────────┘
                                                    │
                                                    ▼
                                pause.json=true (any warning) → ABORT
```

---

## 3 · LinkedIn 账号映射（与文件 2 bootstrap 一致）

| 账号 | 主题 | Published profile slug |
| --- | --- | --- |
| `david-loan@linkedin.com` | loaninca (DSCR 贷款) | `in/davidloan-dscr`（示例，非真实） |
| `david-rent@linkedin.com` | rentalinca (加州房东) | `in/davidrent-ca` |
| `david-buddha@linkedin.com` | fopusha (海外华人佛事) | `in/davidbuddha-en` |

每个账号根目录有：

```
~/geo-seo-rpa/state/linkedin/<account>/
├── storage.json          # 含 li_at cookie
├── fingerprint.json      # viewport = 1440x900；timezone = America/Los_Angeles
└── last-post.json        # 上一条发布时间戳；24h guard
```

---

## 4 · 每周输入 / 输出契约

### 4.1 Input（来自 owner 邮箱 or 本地 content 目录）

```
~/geo-seo-rpa/content/this-week/linkedin/
├── 01-loan-dscr-secrets.md       # 1300 字以内长文
├── 02-rent-ab1482-checklist.md
├── 03-buddha-ancestor-tablet.md
└── pinned/
    ├── 01-loan.md                # 250–400 字置顶讨论（结尾给出原文链接）
    ├── 02-rent.md
    └── 03-buddha.md
```

Markdown 第一行 `# ` 是 post 标题（LinkedIn 强制）。
正文第 2 段开始就是内容。
Pinned 文件同理。

### 4.2 Output（必须写入）

```json
{
  "id": "li-2026-07-08-loan-01",
  "platform": "linkedin",
  "account": "david-loan@linkedin.com",
  "title": "Why most California DSCR applicants fail the first try",
  "post_url": "https://www.linkedin.com/posts/davidloan-dscr_xxxxx",
  "pinned_comment_url": null,
  "tags_used": ["#DSCRLoan", "#CaliforniaRealEstate", "#RealEstateInvesting"],
  "publish_ts": 1720447200,
  "self_published": false,
  "kickoff_token": "owner-kickoff-2026-07-08T07:55",
  "screenshots": [
    "linkedin/loan-01-step1-start.png",
    "linkedin/loan-01-step4-posted.png",
    "linkedin/loan-01-step5-pinned.png"
  ]
}
```

---

## 5 · Step-by-step

---

### Step 1：拉 owner kick-off token

```python
from utils import ensure_kickoff
token = ensure_kickoff(action="publish-linkedin")
# 必须 owner-kickoff-YYYY-MM-DDThh:mm
```

> 没有 token 不许动 LinkedIn。

---

### Step 2：载入周输入文件

```python
import json, re
from pathlib import Path

posts = []
for site in ["loan", "rent", "buddha"]:
    body = Path(f"~/geo-seo-rpa/content/this-week/linkedin/{site_padded(site)}-*.md").expanduser()
    pinned = Path(f"~/geo-seo-rpa/content/this-week/linkedin/pinned/{site_padded(site)}.md").expanduser()
    title = body.read_text(encoding="utf-8").splitlines()[0][2:].strip()
    posts.append({
        "site": site,
        "account": SITE_TO_ACCOUNT[site],
        "body_path": body,
        "pinned_path": pinned,
        "title": title,
        # 拼出 LinkedIn Post 正文：从第 3 行开始，跳过"# title"与空行
        "body_md": "\n".join(body.read_text(encoding="utf-8").splitlines()[2:]),
    })
assert len(posts) == 3
```

---

### Step 3：检查 24h 配额 + LinkedIn-specific guards

```python
import time, json
from pathlib import Path

for p in posts:
    lp = Path(f"~/geo-seo-rpa/state/linkedin/{p['account']}/last-post.json").expanduser()
    if lp.exists():
        d = json.loads(lp.read_text())
        if time.time() < d.get("next_allowed_ts", 0):
            abort(f"24h guard on {p['account']}")

# Word count check：每篇正文 ≤ 1300 words（LinkedIn 算法最佳 1100–1300）
from utils import word_count
assert all(800 <= word_count(p["body_md"]) <= 1300 for p in posts)

# Hashtag check：3–5 个
import re
for p in posts:
    tags = re.findall(r"#\w+", p["body_md"])
    assert 3 <= len(tags) <= 5, f"hashtag count off for {p['site']}: {tags}"

# Title clickbait blacklist
from utils import title_lint
for p in posts:
    title_lint(p["title"])  # 命中黑词则抛错
```

---

### Step 4：启动浏览器 + 加载 storage_state

> 启动顺序必须**先开第 1 篇的账号 → 发完 → 关 context → 等 8 分钟 → 自评 → 关 → 切下个账号**。绝对禁止两个 LinkedIn context 同时在线。

```python
ctx = browser.new_context(
    storage_state=f"~/geo-seo-rpa/state/linkedin/{post['account']}/storage.json",
    **fingerprint_for(post["account"])
)
page = ctx.new_page()
page.goto("https://www.linkedin.com/feed/", wait_until="domcontentloaded")
shot("step4-feed.png", page)
```

---

### Step 5：发 Post

#### 5.1 找到"Start a post"

```python
page.locator("button:has-text('Start a post')").first.click()
page.wait_for_selector("div[role='textbox'][aria-multiline='true']", timeout=15000)
shot("step5-1-editor-open.png", page)
```

#### 5.2 用 evaluate 注入文本（绕 contenteditable + shadow DOM）

```python
PAGE_JS = """
(args) => {
    const { html, title } = args;
    const editor = document.querySelector("div[role='textbox'][aria-multiline='true']");
    if (!editor) throw "editor missing";
    editor.focus();
    // 先压入 title
    document.execCommand('insertText', false, title + '\\n\\n');
    // 再压入 html
    document.execCommand('insertHTML', false, html);
}
"""
html = md_to_html(post["body_md"])   # 我们的工具函数
page.evaluate(PAGE_JS, {"html": html, "title": post["title"]})
shot("step5-2-text-filled.png", page)
```

> **铁律**：使用 `document.execCommand('insertText')` 而非 `keyboard.type`——前者保留 LinkedIn 的内部 character model，**不会触发 ghost typing flag**。

#### 5.3 等 90 秒（模拟人在改字）

```python
page.wait_for_timeout(random.randint(85_000, 110_000))
# 这一段时间内允许插入 2-3 处小删改
patches = markdown_minor_edits(post["body_md"])
for title, where, repl in patches:
    # 简单替换一个词或一个标点
    ...
shot("step5-3-edited.png", page)
```

> 假"反复斟酌"是从平台检测角度的必需品。先打完一稿直接发布 = 100% 机器人模式。

#### 5.4 发布

```python
page.locator("button:has-text('Post')").last.click()
# 等 URL 变化（LinkedIn 通常重定向到 # 或 fixed post URL）
page.wait_for_url(re.compile(r"/feed/|^https://www\.linkedin\.com/feed/$"), timeout=15000)
shot("step5-4-posted.png", page)
```

> **铁律**：发帖后**不立即关闭 context**——必须先做完 step 6 的置顶评论。

---

### Step 6：写置顶评论（8 分钟内）

#### 6.1 找到自己的新帖

```python
# 跳到帖子自己的活动详情
page.goto(f"https://www.linkedin.com/in/{get_account_slug(post['account'])}/", wait_until="domcontentloaded")
# 定位最近一条 post
recent = page.locator("div.feed-shared-update-v2").first
shot("step6-1-located.png", page)

# 必须确认这是自己刚发的（作者头像 = 自己头像）
self_name = page.locator("nav .profile-card-name").first.text_content().strip()
post_author = recent.locator("a.update-components-actor__name").first.text_content().strip()
assert self_name in post_author or post_author in self_name, \
    f"post author mismatch {self_name!r} vs {post_author!r}"
```

#### 6.2 点 "Comment" 并写入置顶讨论

```python
recent.locator("button[aria-label*='Comment']").first.click()
page.wait_for_selector("div[role='textbox'][aria-multiline='true']")
pinned_html = md_to_html(post["pinned_md"])
page.evaluate(PAGE_JS, {"html": pinned_html, "title": ""})  # 置顶评论无 title
page.wait_for_timeout(random.randint(60_000, 100_000))  # 改字模拟
recent.locator("button[aria-label*='Post comment']").first.click()
shot("step6-2-pinned.png", page)
```

#### 6.3 立刻把这条评论**PIN**（操作员必做的 1 步）

> LinkedIn 桌面网页**不能**通过 API 或脚本"client-side pin"，原因：置顶是只有本人账号在原帖上方的"more"菜单里手动操作的特权，且涉及 IPC 二次验证。
> **AI 不应该模拟点击 pin 按钮**，而应该**通知 owner，owner 手动在 5 分钟内打开 LinkedIn 客户端 pin 一下**。
>
> 因此 AI 写完置顶评论后立刻：
```python
notify_owner(
    type="manual_pin_request",
    post_id=post_id,
    deadline_secs=300,
    message=f"Please pin this comment within 5 minutes: {post_url}#latest-comment"
)
```

> 这是一个**刻意暴露给 owner 的人工步骤**，不能完全自动化。LinkedIn 把 pin 视为高风险 activity（一旦滥用会被认为是 fake engagement）。

---

### Step 7：更新状态 + 24h guard

```python
append_status({
    "id": f"li-{date.today().isoformat()}-{post['site']}",
    "platform": "linkedin",
    "account": post["account"],
    "title": post["title"],
    "publish_ts": int(time.time()),
    "kickoff_token": token,
    "tag_count": len(re.findall(r"#\w+", post["body_md"])),
    "pinned_status": "awaiting_owner_pin",
})

update_last_post(post["account"], next_allowed=int(time.time()) + 24 * 3600)
```

---

### Step 8：关闭 context，等下条

```python
ctx.close()
page.wait_for_timeout(random.randint(40, 90) * 60 * 1000)   # 40–90 分钟
```

---

### Step 9：三篇全部完成 → 切到 Step 10（4.3 周六评论回复）

---

### Step 10（4.3）：周六批量回复评论

> 规则：每周六 09:00 PT 把当周 3 条 LinkedIn Post 的全部未回复评论**亲自**扫一遍挑出值得回的那部分，写定制回复（**非模板化**）。

```python
posts = load_weekly_linkedin_posts()   # 来自 content-status.json
for post in posts:
    comments = fetch_post_comments(post["url"])    # 用 LinkedIn API 是更稳的；需 owner 提供 offline token
    for c in comments:
        if c["author_id"] not in BLACKLIST and not c["already_replied"]:
            reply = generate_contextual_reply(  # 必须基于评论原文语义，不是模板
                post_body=post["body_md"],
                comment_text=c["body"],
                persona=post["site"],  # "loan" / "rent" / "buddha"
            )
            post_linkedin_reply(post, c["urn"], reply)
            shot(f"step10-reply-{c['urn']}.png", page)
```

> **铁律**：
>
> - 单条 Post **最多 6 条 owner-pre-blessed 回复**，其余礼貌"like"代币不写文字
> - 回复必须包含 1–2 个长句引用对方原话的具体部分（"you said X — in our case we ran into Y" style），不写空泛的"谢谢分享"
> - 不在回复里放外链（外链仅在置顶评论）
> - 不在回复里推销 / 不发"DM me for details"

---

## 6 · 反检测清单（每周 review）

| 检查 | 通过条件 |
| --- | --- |
| 同时在线 context 数 | **≤ 1**。打开第二个立刻触发异常 |
| session cookie li_at | 每个账号独立，从不共用 |
| 同一发帖时间间隔 | **≥ 40 分钟** |
| 同一 IP 跨账号操作 | 当日操作顺序：david-loan → david-rent → david-buddha（与 bootstrap 阶段顺序一致）|
| Hashtag 数量 | 每帖 3–5 个，正文内嵌，不用 `#` 在末尾堆 |
| 外部链接出现次数 | 每贴 ≤ 1 个，且仅出现在置顶评论，**不出现在正文** |
| 发布时间 | 周二/三/四 08:00 PT ± 30 min；不允许发在 LinkedIn 系统检测"深夜流量波段"上 |
| "AI-generated content" 标记 | LinkedIn 在 2024 年起对 AI 内容贴 policy warning，但我们有 1.5 倍人类伪装（延时、删改、改字、引述具体数字）已可规避 |

---

## 7 · 错误处理矩阵

| 异常 | 动作 |
| --- | --- |
| Cookie 失效（被强制重登录） | screenshot + `pause.json` 置位 + owner 通知 |
| `unusual sign-in` 红条 | 同上，但**该账号 24h guard 重置为 7 天** |
| Editor DOM 找不到 | screenshot + mark publish_fail + abort 本篇（继续走下篇） |
| 主页 / feed 显示 `restricted account` | 立即终止本周一切 LinkedIn 操作，进入文件 6 通报链 |
| 帖子被 LinkedIn 自动加"敏感词" 黄条 | screenshot + owner 通知；脚本不擅自改字 |
| 频率警告 `You're posting too often` | 关闭 context + 中止本周剩余；下周一重新启动 |

---

## 8 · 不允许 AI 做的事

- ❌ 任何时刻同时登录 2 个 LinkedIn 账号
- ❌ 替 owner 手动 PIN 评论（这条是 owner 唯一必须人工做的）
- ❌ 短于 30 秒内切换账号 / context
- ❌ 在正文放外链（外链永远在置顶评论）
- ❌ 评论他人 Profile 主页（只能在原帖评论）
- ❌ 联系非 owner 的陌生人发 DM
- ❌ 修改账号的 name / headline / about / experience / featured——文件 2 bootstrap 阶段后冻结尾生
- ❌ 改 LinkedIn 隐私设置
- ❌ 同意 / 拒绝 connection request（除非文件 5 允许的范围）
- ❌ 给不能 100% 自然读懂的评论写自动回复（step 10.4 的 `generate_contextual_reply` 若置信度低，宁可跳过——`PRE-BLESSED` 限制）

---

## 9 · 完成判定

- ✅ 3 个账号 `last-post.json` 的 `next_allowed_ts` 均 ≥ 当前 ts + 24h
- ✅ `content-status.json` 有 3 条 `platform=linkedin publish_ok=true`
- ✅ 3 条 post URL 都能被 owner 在浏览器打开 → 看到置顶评论在第一楼
- ✅ 当周 4.3 周六评论回复日志 `weekly-replies-{week}.jsonl` 非空
- ✅ 没有任何时刻在 `pause.json` 看到 true 之后还写过 LinkedIn（除文件 6 主动"unwind"流程）

满足以上 → 进入文件 5 Quora + Reddit 剧本。
