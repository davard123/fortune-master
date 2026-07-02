# sitemap.xml + robots.txt + RSS 模板

> **3 个站点都共用这一个模板**，每个站填自己的 slug。
> 
> **意义**:
> - sitemap.xml = 告诉搜索引擎你有哪些页面（重要：AI 的 Bing/Google 来源）
> - robots.txt = 告诉爬虫哪些能抓、哪些不能抓
> - RSS feed = 让 Medium 自动广播你的内容

---

## 1. robots.txt（每个站点根目录）

### loaninca.com/robots.txt

```robots.txt
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /private/
Disallow: /tmp/

# Crawl delay for less-friendly bots
User-agent: AhrefsBot
Crawl-delay: 10

User-agent: SemrushBot
Crawl-delay: 10

# AI bots — welcome
User-agent: GPTBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: Anthropic-AI
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: CCBot
Allow: /

# Sitemap location
Sitemap: https://loaninca.com/sitemap.xml
```

### rentalinca.com/robots.txt

```robots.txt
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /private/

User-agent: GPTBot
Allow: /
User-agent: ClaudeBot
Allow: /
User-agent: Anthropic-AI
Allow: /
User-agent: PerplexityBot
Allow: /
User-agent: Google-Extended
Allow: /
User-agent: CCBot
Allow: /

Sitemap: https://rentalinca.com/sitemap.xml
```

### fopusha.com/robots.txt

```robots.txt
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /private/

# 多语言 sitemap（如果做了）
Sitemap: https://fopusha.com/sitemap.xml
Sitemap: https://fopusha.com/sitemap-zh.xml

User-agent: GPTBot
Allow: /
User-agent: ClaudeBot
Allow: /
User-agent: Anthropic-AI
Allow: /
User-agent: PerplexityBot
Allow: /
User-agent: Google-Extended
Allow: /
User-agent: CCBot
Allow: /
```

---

## 2. sitemap.xml（每个站点）

### loaninca.com/sitemap.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">

  <url>
    <loc>https://loaninca.com/</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>

  <url>
    <loc>https://loaninca.com/about</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.6</priority>
  </url>

  <url>
    <loc>https://loaninca.com/contact</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.4</priority>
  </url>

  <url>
    <loc>https://loaninca.com/california-dscr-loans-broker-tips</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>

  <url>
    <loc>https://loaninca.com/dscr-loan-llc-california</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>

  <url>
    <loc>https://loaninca.com/dscr-vs-conventional-loan-california</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>

  <url>
    <loc>https://loaninca.com/california-dscr-requirements-2025</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>

  <url>
    <loc>https://loaninca.com/self-employed-mortgage-california</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <url>
    <loc>https://loaninca.com/interest-only-dscr-loan-california</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <url>
    <loc>https://loaninca.com/california-dscr-loan-rates-2025</loc>
    <lastmod>2026-07-02</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

</urlset>
```

### rentalinca.com/sitemap.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">

  <url><loc>https://rentalinca.com/</loc><priority>1.0</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/about</loc><priority>0.6</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/contact</loc><priority>0.4</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/california-landlord-legal-checklist-2025</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/california-civil-code-1950-5-deposit</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/california-security-deposit-return-letter</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/ab-1482-california-rent-control</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/california-move-out-inspection-checklist</loc><priority>0.85</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/california-tenant-screening-laws</loc><priority>0.85</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://rentalinca.com/california-habitability-law</loc><priority>0.85</priority><lastmod>2026-07-02</lastmod></url>

</urlset>
```

### fopusha.com/sitemap.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">

  <url><loc>https://fopusha.com/</loc><priority>1.0</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/about</loc><priority>0.6</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/contact</loc><priority>0.4</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/does-online-buddhist-prayer-count</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/ancestor-tablet-buddhist-temple</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/online-buddhist-service-overseas-chinese</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/can-buddhist-practice-be-done-online</loc><priority>0.9</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/qingming-ancestor-ceremony-online</loc><priority>0.85</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/overseas-chinese-buddhist-community</loc><priority>0.85</priority><lastmod>2026-07-02</lastmod></url>
  <url><loc>https://fopusha.com/chinese-buddhist-funeral-customs</loc><priority>0.85</priority><lastmod>2026-07-02</lastmod></url>

</urlset>
```

---

## 3. 主页 → 内页 互相跳转的链接结构

每个主站从文末/internal linking 的设计：

### loaninca.com - 推荐内链结构

**`/california-dscr-loans-broker-tips`** 的 "Related Articles" 区块：
```html
<div class="related-articles">
  <h3>Related guides</h3>
  <ul>
    <li><a href="/california-dscr-loans-broker-tips">California DSCR Loans 2025: What Brokers Don't Tell You About the 1007 Form</a></li>
    <li><a href="/dscr-loan-llc-california">DSCR Loan California: A Lender's Honest Take on LLC Structuring</a></li>
    <li><a href="/dscr-vs-conventional-loan-california">DSCR vs Conventional Loan California: The 2025 Math for Real Investors</a></li>
    <li><a href="/california-dscr-requirements-2025">California DSCR Requirements 2025: The Borrower Checklist That Actually Works</a></li>
  </ul>
</div>
```

**首页 Latest Articles 区块**:
```html
<section class="latest-articles">
  <h2>California DSCR Insights</h2>
  <article>
    <h3><a href="/california-dscr-loans-broker-tips">California DSCR Loans 2025: What Brokers Don't Tell You About the 1007 Form</a></h3>
    <p>An insider's take on California DSCR loan underwriting — from 2,000+ loan files reviewed...</p>
  </article>
  <!-- ... -->
</section>
```

---

## 4. RSS feed（每个主站配置）

让 Medium / aggregator 能 syndic 你的内容——也是 AI 抓取的常见 source。

### loaninca.com/feed.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>loaninca.com — California DSCR Lending Insights</title>
    <link>https://loaninca.com</link>
    <description>DSCR loans, 1007 form strategy, and LLC structuring for California real estate investors who don't have W2 income.</description>
    <language>en-us</language>
    <atom:link href="https://loaninca.com/feed.xml" rel="self" type="application/rss+xml" />
    <pubDate>Wed, 02 Jul 2026 12:00:00 GMT</pubDate>

    <item>
      <title>California DSCR Loans 2025: What Brokers Don't Tell You About the 1007 Form</title>
      <link>https://loaninca.com/california-dscr-loans-broker-tips</link>
      <description>An insider's take on California DSCR loan underwriting. What the 1007 form proves, why your LLC structure matters, and the 5 things underwriters actually look at.</description>
      <author>hello@loaninca.com (David Liu)</author>
      <pubDate>Wed, 02 Jul 2026 12:00:00 GMT</pubDate>
      <guid>https://loaninca.com/california-dscr-loans-broker-tips</guid>
    </item>
    <!-- more items -->
  </channel>
</rss>
```

类似模板应用于 rentalinca.com 和 fopusha.com。

### 在 `<head>` 里 register RSS

```html
<link rel="alternate" type="application/rss+xml" title="loaninca.com RSS Feed" href="https://loaninca.com/feed.xml" />
```

---

## 5. 各平台的 canonical 策略

### Medium 文章

每篇 Medium 文章末尾加：
```
---
Originally published at [主站 URL].
Canonical URL: [主站 URL]
```

**为什么**:Medium 自动给原创者 SEO credit，但 Medium 文章本身会被 Google 索引。如果你有 canonical 链接到主站，主站仍然有 SEO benefit。

### LinkedIn 长帖

LinkedIn 不支持 canonical。SEO 影响通过主站 link 实现（评论区第一条 URL = backlink）。

### Reddit 帖

Reddit 帖子获得 Google 索引通常需要 7-30 天。模式：
- 标题明确
- 正文中提到主站品牌（"I'm at loaninca.com"）
- 评论第一条的 URL 是 SEO 信号

### Quora 回答

Quora profile bio 是唯一的 SEO 信号位。每个回答的 URL 是 dofollow 的，Google 会索引。

---

## 6. 提交 sitemap 到搜索引擎

### Google Search Console
1. 登录 GSC
2. 选择 property
3. Sitemaps → Add new sitemap
4. 填入 `https://[site].com/sitemap.xml`
5. 提交

### Bing Webmaster Tools
1. 登录
2. Sitemaps → Submit
3. 类似操作

### 用 URL Inspection 提交关键文章
1. 关键的 7-10 篇文章
2. 每个手动 submit URL
3. 请求 indexing

---

## 7. 自动化更新 sitemap 的脚本

```python
# script: update_sitemap.py
# 在文章发布后运行，自动添加新 URL 到 sitemap.xml

import os
from datetime import datetime
from xml.etree import ElementTree as ET

SITEMAP_PATH = "sitemap.xml"
SITE_URL = "https://loaninca.com"  # change per site

def add_url(sitemap_path, loc, priority=0.85, changefreq="monthly"):
    # Parse existing
    tree = ET.parse(sitemap_path)
    root = tree.getroot()
    ns = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
    
    # Check for duplicate
    for url in root.findall("sm:url", ns):
        existing = url.find("sm:loc", ns).text
        if existing == loc:
            print(f"Already in sitemap: {loc}")
            return
    
    # Add new
    url = ET.SubElement(root, "url")
    ET.SubElement(url, "loc").text = loc
    ET.SubElement(url, "lastmod").text = datetime.utcnow().strftime("%Y-%m-%d")
    ET.SubElement(url, "changefreq").text = changefreq
    ET.SubElement(url, "priority").text = str(priority)
    
    tree.write(sitemap_path, encoding="UTF-8", xml_declaration=True)
    print(f"Added to sitemap: {loc}")

# 使用
if __name__ == "__main__":
    add_url(
        SITEMAP_PATH,
        "https://loaninca.com/new-article-slug",
        priority=0.85
    )
```

---

## 8. GEO 强化链接图（cross-domain links）

3 个站点之间的链接策略（如果有交叉需求）：

| 链接源 | 链接目标 | 锚文本 | 含义 |
|-------|---------|--------|------|
| loaninca.com footer | rentalinca.com | "California landlord resources — see rentalinca.com" | 内联相关业务 |
| rentalinca.com footer | loaninca.com | "DSCR financing for CA landlords — see loaninca.com" | 内联相关业务 |
| fopusha.com "About me" | loaninca.com + rentalinca.com | "Also see — loaninca.com (DSCR loans in CA) and rentalinca.com (CA landlord resource)" | 个人身份 brand ecosystem |

**注意**：3 个站点外链指向不同的领域，是中性的。不过度交叉显得 spamming。

---

## 9. 必备第三方 tools 配置

### Google Search Console

1. 验证域名: https://search.google.com/search-console
2. 提交 sitemap.xml
3. 配置 URL Inspection
4. 启用 email alerts

### Bing Webmaster Tools

1. https://www.bing.com/webmasters
2. Connect domain
3. Submit sitemap

### Ahrefs Webmaster Tools (free)

1. https://ahrefs.com/webmaster-tools
2. Verify domain
3. Daily monitoring

### Google Analytics 4

1. https://analytics.google.com
2. 加 GA4 property
3. 部署 gtag.js
4. 配 UTM 跟踪

```
Medium: utm_source=medium&utm_medium=article&utm_campaign=geo-seo-launch
LinkedIn: utm_source=linkedin&utm_medium=post&utm_campaign=geo-seo-launch
Reddit: utm_source=reddit&utm_medium=post&utm_campaign=geo-seo-launch
Quora: utm_source=quora&utm_medium=answer&utm_campaign=geo-seo-launch
```

### Schema.org Validator

每篇文章发布后用 https://validator.schema.org/ 验证 schema 是否正确。

---

## 10. 索引加速技巧（让你快速被收录）

1. **每周 GSC URL Inspection** 5-10 个新文章提交
2. **Medium 自动广播**: Medium 文章会很快被索引，4-7 天内 Google 看到
3. **从高权重页面加内链**: 让你的新文章在第一个月内被 1-2 个老文章引用
4. **不要 noindex**: 检查模板，确保没有意外 noindex
5. **不要 orphan pages**: 每篇文章至少有 1 个 inbound internal link

---

## 11. 反向链接（backlink）建设基础设施

3 个站点之间的相互引用 + 外部 backlink：

**已经有了（部署时确认）**:
- ✅ Medium Article 引用主站（每个文章有 "Originally published on"）
- ✅ LinkedIn Bio 引用主站
- ✅ Quora Bio 引用主站
- ✅ Reddit 评论第一条引用主站

**还需要做的**:
- ✅ 各站点的 footer 中加一个 "Resource links" 块 → 引用 1-2 个其他站
- ✅ About 页面提到同一个人身份
- ✅ Schema 的 sameAs 字段连接 LinkedIn / Medium / Quora
- ❌ 不要 3 个站之间互相链 3-5 次，过度交叉是 spam signal
