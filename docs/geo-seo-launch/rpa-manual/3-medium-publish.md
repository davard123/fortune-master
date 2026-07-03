# 3 · Medium 发布剧本（每周 3 篇 · 3 个 Publication）

> 本文档是上一份 `2-account-bootstrap.md` 的下游执行剧本：账号已经预热、本地 `storage_state` 已经注入、Publication 已经创建完毕。
> AI 仅在 **owner 明确发出 weekly kick-off 信号**（见 `1-rpa-framework.md §4 kick-off token`）后才执行本剧本。

---

## 0 · Medium 平台特殊性 · 开始前必须清楚

| 项 | 平台规则 / 我们的对策 |
| --- | --- |
| 单账号 24 小时发文上限 | Medium 没有公开阈值，但**经验值是同一账号当日第 4 篇开始异常高概率被限流**。本周对策：**每个 Medium 账号每周只发 1 篇**，3 篇分别走 3 个账号。 |
| 编辑器 | Medium 的发布编辑器采用 contenteditable + ProseMirror，**不能简单 `page.fill`**。必须用 `evaluate` 操作原生光标/选区。 |
| Featured Image | 必须尺寸 ≥ 1400×788，且放在封面位（编辑器的 "Add a cover image" 按钮）；未设封面则 Medium 给极低推流权重。 |
| Canonical URL | Medium 支持原文 `canonical` 链接设置——这是我们把外链指向 3 个站点的关键开关。**遗漏此步等于 GEO 失效**。 |
| Publication 投稿 | 部分 Publication（特别是我们新建的）需要点 "Submit to publication" 后人工审核。本剧本默认你已被加入 Publication editorial 名单，可直接发布。 |
| Tag 选择 | 每篇最多 5 个 tag；选错 tag 等于推给错的受众，正反馈慢。 |
| "Draft vs Publish" 区分 | 写完一定是显式点 Publish，不是 Save Draft。脚本必须检测 URL 是否变为 `https://medium.com/p/{hash}` 才算成功。 |
| 客户端交互 | Medium 对`puppeteer/playwright`自动化会用 CloudFront + 指纹检测。**必须沿用账号预热阶段同一份 storage_state 与同一份 fingerprint**（见 `2-account-bootstrap.md §3`）。 |

---

## 1 · 输入与输出契约（pre/post 状态）

### 1.1 Input（执行前置状态）

```
$ tree ~/geo-seo-rpa/state/medium/
├── david-loan@medium.com/
│   ├── storage.json         # 已注入的登录态，由 bootstrap 完成
│   └── last-publish.json    # 最近一篇发布时间戳；24h 内禁止再发
├── david-rent@medium.com/
│   ├── storage.json
│   └── last-publish.json
└── david-buddha@medium.com/
    ├── storage.json
    └── last-publish.json
```

每个账号根目录还有一个 `fingerprint.json`，记录：

```json
{
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ...",
  "viewport": {"width": 1440, "height": 900},
  "locale": "en-US",
  "timezone": "America/Los_Angeles",
  "webgl_vendor": "Google Inc. (NVIDIA)",
  "webgl_renderer": "ANGLE (NVIDIA, NVIDIA GeForce RTX 4070 Direct3D11 vs_5_0 ps_5_0)"
}
```

> 这些值与 bootstrap 阶段**完全一致**。一旦改 fingerprint，Medium 会视为新设备 → 强验证。

### 1.2 Output（执行后状态）

发布成功 → 立即在 `~/geo-seo-rpa/state/content-status.json` 写入：

```json
{
  "id": "m-2026-07-02-loan-01",
  "platform": "medium",
  "account": "david-loan@medium.com",
  "publication": "DSCR Loan Hub (loaninca)",
  "title": "California DSCR Loans 2025: What Self-Employed Investors Must Know",
  "url": "https://medium.com/p/abc123def456",
  "canonical": "https://loaninca.com/articles/california-dscr-2025",
  "tags": ["Real Estate Investing", "DSCR Loan", "California"],
  "cover_image_path": "~/geo-seo-rpa/assets/medium/loan-dscr-2025.jpg",
  "publish_timestamp": 1720036800,
  "kickoff_token": "owner-kickoff-2026-07-02T08:00",
  "screenshots": [
    "~/geo-seo-rpa/screenshots/medium/loan-01-step1-editor.png",
    "...",
    "~/geo-seo-rpa/screenshots/medium/loan-01-step9-published.png"
  ]
}
```

并更新 `last-publish.json`：

```json
{
  "last_publish_ts": 1720036800,
  "next_allowed_ts": 1720123200   // +24h
}
```

> **铁律**：必须在 screenshot 中看到 `selector:'article h1'` 已变为目标标题、`selector:'meta[rel=canonical]'` 已指向目标 URL，才允许标记 publish ok。

---

## 2 · 总体调度（周节奏）

| 周中 | 动作 | 备注 |
| --- | --- | --- |
| 周一 08:00 PT | `loaninca` 文章发布 → `david-loan@medium.com` → Publication: `DSCR Loan Hub` | Finance 内容，正反馈最慢，所以放在周一头 |
| 周二 08:00 PT | `rentalinca` 文章发布 → `david-rent@medium.com` → Publication: `California Landlord Notes` |  |
| 周四 08:00 PT | `fopusha` 文章发布 → `david-buddha@medium.com` → Publication: `海外华人佛学参考` | 中文内容，tag 用 `#佛学 #海外华人 #在线祈福`，Publication 设为中文写作 |

> 周三、周五、周六、周日留作 **organic reply / cross-link / engagement**（见文件 5）。

---

## 3 · AI 必须做的事（step-by-step）

> 每一步对应一段 Playwright Python 代码片段。AI 在执行时按编号顺序跑，每步结束都做 screenshot + JSON 状态写入。

---

### Step 1：拉取 kick-off token，检查 owner 授权

```python
from utils import read_state, ensure_kickoff

token = ensure_kickoff(action="publish-medium")
print(f"[OK] owner kick-off received: {token}")
```

> **铁律**：本步骤若 5 秒内没拿到 `owner-kickoff-*` token，**立即终止**。绝不"自由发挥"地开始改 Medium。

---

### Step 2：载入本周待发文章

```python
from pathlib import Path
import json

week_dir = Path("~/geo-seo-rpa/content/this-week/")
articles = []
for md in sorted(week_dir.glob("*.md")):
    meta_line = md.read_text(encoding="utf-8").splitlines()[0]
    assert meta_line.startswith("# "), "must start with H1 title"
    payload = {
        "site": extract_site(md),       # "loaninca" / "rentalinca" / "fopusha"
        "title": meta_line[2:].strip(),
        "body_md": md.read_text(encoding="utf-8"),
        "cover": week_dir / md.name.replace(".md", ".jpg"),
        "canonical": extract_canonical(md),
        "tags": extract_tags(md),
    }
    articles.append(payload)

assert len(articles) == 3, f"this week expects 3, got {len(articles)}"
```

> **铁律**：articles 必须**恰好 3 篇**，且 site 分布必须为 `1 loaninca + 1 rentalinca + 1 fopusha`。否则不开始。

---

### Step 3：根据 site 选 account + publication

```python
ROUTE = {
    "loaninca":   ("david-loan@medium.com",   "DSCR Loan Hub (loaninca)"),
    "rentalinca": ("david-rent@medium.com",   "California Landlord Notes"),
    "fopusha":    ("david-buddha@medium.com", "海外华人佛学参考"),
}

for a in articles:
    account, pub = ROUTE[a["site"]]
    a["account"] = account
    a["publication"] = pub
```

> 严禁文章 ↔ 账号错配（例如把 loaninca 文章发到 rent 账号），否则 Publication 推流归类错乱。

---

### Step 4：检查 24h 配额的 guard

```python
import time, json
from pathlib import Path

def ok_to_publish(account):
    p = Path(f"~/geo-seo-rpa/state/medium/{account}/last-publish.json").expanduser()
    if not p.exists():
        return True
    d = json.loads(p.read_text())
    return time.time() >= d.get("next_allowed_ts", 0)

for a in articles:
    assert ok_to_publish(a["account"]), \
        f"24h guard tripped on {a['account']} (next allowed in {mins} min). Abort."
```

---

### Step 5：准备 featured image（已存在于 local，不上传）

> 封面图**owner 已手动放好**在 `~/geo-seo-rpa/assets/medium/{site}-{slug}.jpg`。AI 只负责 `set_input_files`。不允许 AI 临时拉网络图片（避免第三方 CDN 指纹关联）。

```python
from utils import assert_image_specs

for a in articles:
    assert_image_specs(
        path=a["cover"],
        min_w=1400, min_h=788,
        max_kb=2048,
        mime={"jpeg", "png"}
    )
```

---

### Step 6：启动浏览器，加载 storage_state

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(
        headless=False,           # 必须 visible，owner 电脑屏幕上要能看到
        args=["--disable-blink-features=AutomationControlled"]
    )
```

---

### Step 7：循环 3 篇文章（每篇 i = 0..2）

#### 7.1 创建新 context（每个账号独立）

```python
ctx = browser.new_context(
    storage_state=f"~/geo-seo-rpa/state/medium/{a['account']}/storage.json",
    **fingerprint_for(a["account"])
)
page = ctx.new_page()
```

#### 7.2 打开编辑器

```python
page.goto("https://medium.com/new-story", wait_until="domcontentloaded")
page.wait_for_selector("div[data-slate-editor='true']", timeout=15000)
shot("step7-2-editor.png", page)
```

> 若登录态失效、被弹 2FA、被弹"unusual activity" → **立即进入文件 6 的 incident 处理流**，**不要尝试绕过**。

#### 7.3 输入标题

```python
page.locator("h3[data-placeholder='Title']").click()
page.keyboard.type(a["title"], delay=random.randint(40, 110))
```

#### 7.4 输入正文

```python
# 把 markdown 转成 Medium 富文本（粗体/标题/列表/链接/代码块）
from utils import md_to_prosemirror

# 注入序列：使用 page.evaluate 把段落写入 Slate 模型
md_to_prosemirror(page, a["body_md"], screenshot_prefix="step7-4")
shot("step7-4-body.png", page)
```

> **markdown→Medium 的关键映射**必须在 `utils/md_to_prosemirror.py` 中实现，且映射表以下面为准：
>
> | Markdown | Medium 渲染 |
> | --- | --- |
> | `# H1`（除第一个外的二级以上标题） | `<h2>` / `<h3>` |
> | `**bold**` | `<strong>` |
> | `[text](url)` | `<a href>`，Medium 会自动加 rel=nofollow，手动绕过需要付费，**忽略** |
> | `> quote` | `<blockquote>` |
> | `- item` | `<ul><li>` |
> | ```` ```code``` ```` | `<pre>` |
> | 普通段落 | `<p>` |

#### 7.5 设置封面图

```python
# Medium 把 "Add a cover image" 放在右下角浮动按钮
page.get_by_role("button", name="Add a cover image").click()
page.wait_for_selector("input[type=file]")
page.set_input_files("input[type=file]", str(a["cover"]))
shot("step7-5-cover.png", page)
```

#### 7.6 配置 canonical URL（**GEO 关键步骤**）

```python
page.locator("button[aria-label='More options']").first.click()
page.locator("button:has-text('Canonical link')").click()
page.locator("input[placeholder*='Paste URL']").fill(a["canonical"])
page.keyboard.press("Enter")
shot("step7-6-canonical.png", page)
```

> **铁律**：canonical 必须填原文路径（如 `https://loaninca.com/articles/california-dscr-2025`），不要填 Medium 自己的文章 URL，否则 GEO 信号回到 Medium 自己。

#### 7.7 添加 tag

```python
for tag in a["tags"][:5]:
    page.locator("input[placeholder*='Add a tag']").fill(tag)
    page.keyboard.press("Enter")
    page.wait_for_timeout(random.randint(800, 2200))
shot("step7-7-tags.png", page)
```

#### 7.8 选择 Publication 并发布

```python
page.locator("button:has-text('Publish')").first.click()
# publication 选择面板
page.locator(f"text='{a['publication']}'").click()
page.locator("button:has-text('Publish now')").click()
shot("step7-8-publishing.png", page)
```

#### 7.9 验证发布成功

```python
# 等跳转到公开阅读页
page.wait_for_url(re.compile(r"https://medium.com/p/"), timeout=30000)
# 必须能看到 H1 与 canonical 都正确
h1 = page.locator("article h1").first.text_content().strip()
can = page.locator("link[rel='canonical']").get_attribute("href")
assert h1 == a["title"], f"title mismatch: {h1!r} != {a['title']!r}"
assert a["canonical"] in can, f"canonical mismatch: {can}"
shot("step9-published.png", page)
```

#### 7.10 更新 content-status.json

```python
from utils import append_status

append_status({
    "id": f"m-{date.today().isoformat()}-{a['site']}",
    "platform": "medium",
    "account": a["account"],
    "publication": a["publication"],
    "title": a["title"],
    "url": page.url,
    "canonical": a["canonical"],
    "tags": a["tags"],
    "publish_ts": int(time.time()),
    "kickoff_token": token,
    "screenshots": screenshots_for(a["site"]),
})

# 更新 24h guard
update_last_publish(a["account"])
```

---

### Step 8：wait 与退出

```python
# 三篇之间随机长延迟，模拟人写间隔
if i < 2:
    mins = random.randint(45, 90)
    print(f"[wait] {mins} min before next article")
    page.wait_for_timeout(mins * 60 * 1000)
```

> 写一篇文章+封图+canonical 在 Medium 上人工约 50–90 分钟。脚本随机休眠 45–90 分钟，再启动下一篇。

---

### Step 9：清理

```python
ctx.close()
# 最后一篇结束后再关闭 browser
if i == len(articles) - 1:
    browser.close()
```

---

## 4 · 反检测要点（必读）

| 风险 | 触发条件 | 对策 |
| --- | --- | --- |
| 输入速度过快 | keydown 间隔 < 30ms | 用 `delay=random.randint(40,110)` |
| 同一 viewport 同一 UA 跨账号 | fingerprint 漂移 | 每账号一套 `fingerprint.json`，永不混用 |
| 网络 IP 异常 | 同账号 1 天内登录洛杉矶和法兰克福 | 用 owner 家庭宽带出口，不要切 VPN |
| 发布间隔过密 | 同一账号 24h 第 4 篇起 | 已在 §2 调度中规避（账号轮换） |
| 标题党夸张词 | "FREE", "Click here", "Earn $5000 today" | title 写入前跑一次 `utils/title_lint.py`；命中黑词则终止本篇，通知 owner |
| 同 canonical URL 复用 | 同一原文 URL 复用会双发重复内容 | `content-status.json` 里检索 `canonical`，已存在则跳过并报警 |
| Featured image 含其他平台水印 | Unsplash 水印、Pexels 角标 | `assert_image_specs` 加 perceptual hash 黑名单 |
| Tag 滥用 | 选 5+ 个不相关 tag | `extract_tags()` 限定每篇最多 5 个，且 topic-relevant |
| 评论风暴 | 同一账号短期内评论他人文 | 不在本剧本范围内，但**24h 全平台评论 ≥ 5 条 → 警告**（见文件 6） |

---

## 5 · 错误处理矩阵

| 异常 | 立即动作 |
| --- | --- |
| `Selector not found` 5s 内 | screenshot + 终止当篇，**不**重试（重试会加速封号） |
| 2FA 弹窗 | screenshot + `state/pause.json` 置位 + 通知 owner，等待 owner 手动换 token |
| `Account restricted` 红条幅 | screenshot + `state/pause.json` 置位 + **该账号 14 天内不再触碰** |
| `Service unavailable / 5xx` | sleep 5 分钟，仅重试 1 次，仍失败则**当日不发** |
| 网络掉线 | playwright 默认抛错，落到 `state/warnings.json`，owner 下次启动时看到 |
| Article 被 Auto-flagged | Medium 极少数会标 `Pending review`，**保留草稿**通知 owner |

---

## 6 · 不允许 AI 做的事

- ❌ 编辑/删除 **任何**已发布的文章（含 owner 已发表过 90 天的）
- ❌ 修改 Publication 的描述、logo、规则、moderators
- ❌ 修改账号头像、bio（除非文件 2 bootstrap 阶段）
- ❌ 评论他人文章（评论剧本在文件 5）
- ❌ 把 canonical 改成 Medium 自家链接
- ❌ 临时从外部 URL 拉图作封面
- ❌ 多篇同主题同标题（含微小改动）
- ❌ 一天内连续发布 2 篇以上
- ❌ 在 draft 里写"AI-generated"出现"this is a draft by an automated tool"
- ❌ 把脚本产生的截图/screenshots 发布到 Image hosting 公网相册

---

## 7 · 完成的判定

每周三篇成功后必须满足：

1. `content-status.json` 出现了 3 条 `platform=medium` 的最新条目
2. 3 条均为 `publish_ok=True`
3. 截图 `step9-published.png` 全部存在
4. 3 个账号的 `last-publish.json` 的 `next_allowed_ts` 均已是未来 24h 以上
5. owner 收到一份 `weekly-summary.txt`（脚本自动生成）：3 个新文章 URL + 3 个 canonical + 截图清单

满足以上 5 条 → 本周 Medium 模块结束，可继续启动 LinkedIn 剧本（文件 4）。
