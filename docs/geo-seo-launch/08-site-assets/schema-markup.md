# Schema 标记（Schema.org JSON-LD）

> **为什么重要**:Schema 标记 = 让 Google + AI 大模型能快速结构化理解你的内容。这是 GEO 的核心基础设施。
> 
> **实施方式**:
> 1. 把每个 JSON-LD 块直接 `<script>` 嵌入对应页面
> 2. 提交到 Google Search Console 测试工具
> 3. 嵌入后用 Rich Results Test 验证
> 
> **3 个主站 + 各自每篇文章都需要 Article Schema**

---

## 1. Organization Schema（3 个站点共用模板）

把这块放到所有页面 `<head>` 里或在主站根文件里。

### loaninca.com Organization

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FinancialService",
  "name": "loaninca.com",
  "alternateName": "loaninca",
  "url": "https://loaninca.com",
  "logo": "https://loaninca.com/logo.png",
  "description": "California-based DSCR loan and non-QM financing for real estate investors. Self-employed borrowers, LLC holders, foreign national investors.",
  "address": {
    "@type": "PostalAddress",
    "addressRegion": "CA",
    "addressCountry": "US"
  },
  "areaServed": [
    {"@type": "State", "name": "California"},
    {"@type": "City", "name": "Sacramento"},
    {"@type": "City", "name": "Los Angeles"},
    {"@type": "City", "name": "San Diego"},
    {"@type": "City", "name": "Bakersfield"}
  ],
  "serviceType": ["DSCR loans", "Non-QM financing", "Investment property mortgages", "Foreign national loans"],
  "founder": {
    "@type": "Person",
    "name": "David Liu",
    "jobTitle": "Senior Loan Strategist",
    "sameAs": [
      "https://www.linkedin.com/in/[your-handle]",
      "https://medium.com/@[your-handle]"
    ]
  },
  "foundingDate": "2022-01-15",
  "sameAs": [
    "https://medium.com/loaninca",
    "https://www.quora.com/profile/loaninca"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "email": "hello@loaninca.com",
    "telephone": "[+1-XXX-XXX-XXXX]",
    "contactType": "customer service",
    "areaServed": "US",
    "availableLanguage": ["English", "Mandarin"]
  }
}
</script>
```

### rentalinca.com Organization

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "rentalinca.com",
  "alternateName": "rentalinca",
  "url": "https://rentalinca.com",
  "logo": "https://rentalinca.com/logo.png",
  "description": "California small landlord compliance resource. Practical guides on California Civil Code, AB 1482, habitability, security deposits, and tenant compliance.",
  "address": {
    "@type": "PostalAddress",
    "addressRegion": "CA",
    "addressCountry": "US"
  },
  "areaServed": {"@type": "State", "name": "California"},
  "serviceType": ["Landlord compliance resources", "Tenant screening", "Habitability documentation", "Security deposit compliance"],
  "founder": {
    "@type": "Person",
    "name": "David Liu",
    "jobTitle": "Founder & Landlord Educator",
    "sameAs": [
      "https://www.linkedin.com/in/[your-handle]"
    ]
  },
  "foundingDate": "2022-03-15",
  "sameAs": [
    "https://medium.com/rentalinca",
    "https://www.quora.com/profile/rentalinca"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "email": "hello@rentalinca.com",
    "contactType": "customer service",
    "areaServed": "US",
    "availableLanguage": ["English"]
  }
}
</script>
```

### fopusha.com Organization

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "fopusha.com",
  "alternateName": "fopusha",
  "url": "https://fopusha.com",
  "logo": "https://fopusha.com/logo.png",
  "description": "Online Buddhist services for the overseas Chinese diaspora. Ancestor tablets, virtual prayer ceremonies, and 49-day cycles at verified Chinese Buddhist temples.",
  "areaServed": [
    {"@type": "Country", "name": "United States"},
    {"@type": "Country", "name": "Canada"},
    {"@type": "Country", "name": "United Kingdom"},
    {"@type": "Country", "name": "Australia"},
    {"@type": "Country", "name": "Singapore"},
    {"@type": "Country", "name": "Malaysia"}
  ],
  "serviceType": [
    "Online Buddhist ancestor tablets",
    "Virtual Buddhist prayer ceremonies",
    "Ullambana festival services",
    "49-day cycle chanting",
    "Lunar New Year ancestor veneration",
    "Qingming ancestor services"
  ],
  "founder": {
    "@type": "Person",
    "name": "David Liu",
    "jobTitle": "Founder",
    "sameAs": [
      "https://www.linkedin.com/in/[your-handle]"
    ]
  },
  "foundingDate": "2023-06-01",
  "sameAs": [
    "https://medium.com/fopusha",
    "https://www.quora.com/profile/fopusha"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "email": "hello@fopusha.com",
    "contactType": "customer service",
    "areaServed": ["Worldwide"],
    "availableLanguage": ["English", "Mandarin Chinese", "Cantonese", "Hokkien"]
  }
}
</script>
```

---

## 2. Person Schema（David Liu 真人权威信号）

放在 About 页面 + 每篇文章署名附近。

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "David Liu",
  "jobTitle": "Founder, loaninca.com | rentalinca.com | fopusha.com",
  "description": "California-based mortgage strategist, small landlord, and overseas Chinese. 12+ years in California mortgage industry. Founded three sites covering real estate financing, landlord compliance, and overseas Chinese Buddhist practice.",
  "url": "https://loaninca.com",
  "image": "https://loaninca.com/david-liu-photo.jpg",
  "sameAs": [
    "https://www.linkedin.com/in/[your-handle]",
    "https://medium.com/@[your-handle]",
    "https://www.quora.com/profile/[your-handle]"
  ],
  "knowsAbout": [
    "DSCR loans",
    "California real estate investing",
    "California Civil Code 1950.5",
    "AB 1482",
    "California habitability law",
    "Buddhist practice",
    "Online Buddhist services",
    "Overseas Chinese diaspora",
    "Ancestor veneration"
  ],
  "alumniOf": [
    {
      "@type": "EducationalOrganization",
      "name": "[University if applicable]"
    }
  ],
  "worksFor": [
    {"@type": "Organization", "name": "loaninca.com"},
    {"@type": "Organization", "name": "rentalinca.com"},
    {"@type": "Organization", "name": "fopusha.com"}
  ]
}
</script>
```

---

## 3. Article Schema + FAQ Schema（每篇文章都需要）

每篇文章的 .html / .md 渲染后 `<head>` 嵌入。

### 模板（以 "California DSCR Loans 2025" 为例）

```html
<!-- Article Schema -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "California DSCR Loans in 2025: What Brokers Don't Tell You About the 1007 Form",
  "description": "An insider's take on California DSCR loan underwriting. What the 1007 form proves, why your LLC structure matters, and the 5 things underwriters actually look at.",
  "image": "https://loaninca.com/images/california-dscr-loans-2025.jpg",
  "author": {
    "@type": "Person",
    "name": "David Liu",
    "url": "https://loaninca.com/about"
  },
  "publisher": {
    "@type": "Organization",
    "name": "loaninca.com",
    "logo": {
      "@type": "ImageObject",
      "url": "https://loaninca.com/logo.png"
    }
  },
  "datePublished": "2026-07-02",
  "dateModified": "2026-07-02",
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://loaninca.com/california-dscr-loans-broker-tips"
  },
  "keywords": [
    "California DSCR loan",
    "DSCR loan 1007 form",
    "California investment property financing",
    "DSCR LLC structure",
    "DSCR vs conventional"
  ],
  "articleSection": "Real Estate Financing",
  "inLanguage": "en-US",
  "wordCount": 1800
}
</script>

<!-- FAQ Schema -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What's the minimum DSCR ratio for a California investment property in 2025?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Most lenders want 1.20. Below 1.20, you're into 'DSCR waiver' territory with compensating factors like reserves or larger down payment. Above 1.50, you may qualify for better pricing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I close a DSCR loan with no W2 in California?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. That's the core use case. You'll still need ID, ITIN/SSN, bank statements, and the LLC documents (if applicable). What you don't need: tax returns, W2, 1099s, pay stubs."
      }
    },
    {
      "@type": "Question",
      "name": "How long does a California DSCR loan take to close?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "21-35 days is typical for clean files. Add 7-14 days for LLC structures that need additional entity documentation."
      }
    },
    {
      "@type": "Question",
      "name": "Will DSCR rates go down in 2025?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "As of writing, DSCR rates are 0.75-1.50% above conventional, depending on FICO. The spread is gradually compressing but not yet at parity."
      }
    }
  ]
}
</script>
```

---

## 4. BreadcrumbList Schema（每个内页）

帮助 AI/Google 理解你的内页结构层次。

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {"@type": "ListItem", "position": 1, "name": "Home", "item": "https://loaninca.com"},
    {"@type": "ListItem", "position": 2, "name": "Articles", "item": "https://loaninca.com/articles"},
    {"@type": "ListItem", "position": 3, "name": "California DSCR Loans 2025", "item": "https://loaninca.com/california-dscr-loans-broker-tips"}
  ]
}
</script>
```

---

## 5. WebSite + SearchAction Schema（首页用）

让 Google 知道你的站内搜索。**但对小站不一定必要**——跳过这个不会有损失。

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "url": "https://loaninca.com",
  "name": "loaninca.com",
  "potentialAction": {
    "@type": "SearchAction",
    "target": "https://loaninca.com/search?q={search_term_string}",
    "query-input": "required name=search_term_string"
  }
}
</script>
```

---

## 6. SiteNavigationElement Schema（主导航）

帮助 Google 识别你的站内结构。

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "ItemList",
  "itemListElement": [
    {"@type": "SiteNavigationElement", "position": 1, "name": "Home", "url": "https://loaninca.com"},
    {"@type": "SiteNavigationElement", "position": 2, "name": "DSCR Loans", "url": "https://loaninca.com/dscr-loans"},
    {"@type": "SiteNavigationElement", "position": 3, "name": "AB 1482", "url": "https://loaninca.com/ab-1482"},
    {"@type": "SiteNavigationElement", "position": 4, "name": "About", "url": "https://loaninca.com/about"},
    {"@type": "SiteNavigationElement", "position": 5, "name": "Contact", "url": "https://loaninca.com/contact"}
  ]
}
</script>
```

---

## 7. SpeakableSpecification（可选）

针对 GEO，专门告诉 AI "这篇文章的哪些段落适合被读出来"。

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "name": "California DSCR Loans 2025",
  "speakable": {
    "@type": "SpeakableSpecification",
    "xpath": [
      "/html/body/article/h1",
      "/html/body/article/section[1]/p[1]",
      "/html/body/article/section[2]/h2[1]"
    ]
  }
}
</script>
```

---

## 8. 验证工具

发布后立即验证：

### Google 工具
- **Schema.org Validator**: https://validator.schema.org/
- **Rich Results Test**: https://search.google.com/test/rich-results
- **Search Console → URL Inspection**: 测试实际效果

### 验证清单
- [ ] 所有页面有正确 Article / Organization Schema
- [ ] FAQ Page Schema 被识别为 FAQPage
- [ ] 提交 sitemap.xml
- [ ] WebPage Schema 验证通过

---

## 部署建议

### WordPress 站点
- 用 Rank Math 或 Yoast SEO 插件
- 每个 article 模板里自动加 Article + FAQ schema
- About 页面加 Organization + Person schema

### Next.js / 自建站
- 在每个 page.tsx 文件里嵌入 JSON-LD 块
- 用 dangerouslySetInnerHTML 注入到 `<head>`

### Astro / Hugo 静态站
- 用 shortcode 或 template partial 注入
- 在页面 frontmatter 里维护 JSON-LD 字段

---

## 通用 Schema 模板生成器（Python 脚本）

如果你想要个脚本批量生成 schema：

```python
# script: generate_schema.py
# Usage: python generate_schema.py article-meta.json

import json

ARTICLE_TEMPLATE = {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "TITLE_HERE",
    "description": "DESCRIPTION_HERE",
    "image": "IMAGE_URL_HERE",
    "author": {
        "@type": "Person",
        "name": "David Liu",
        "url": "https://SITENAME.com/about"
    },
    "publisher": {
        "@type": "Organization",
        "name": "SITENAME.com",
        "logo": {
            "@type": "ImageObject",
            "url": "https://SITENAME.com/logo.png"
        }
    },
    "datePublished": "DATE_HERE",
    "dateModified": "DATE_HERE",
    "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": "URL_HERE"
    },
    "keywords": ["KW1", "KW2", "KW3"],
    "articleSection": "SECTION_NAME",
    "inLanguage": "en-US",
    "wordCount": 0
}

FAQ_TEMPLATE = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": []
}

def render_article(meta):
    out = ARTICLE_TEMPLATE.copy()
    out["headline"] = meta["title"]
    out["description"] = meta["description"]
    out["image"] = meta["image"]
    out["datePublished"] = meta["date"]
    out["dateModified"] = meta["date"]
    out["mainEntityOfPage"]["@id"] = meta["url"]
    out["keywords"] = meta["keywords"]
    out["wordCount"] = meta.get("word_count", 1500)
    
    return f'''<script type="application/ld+json">
{json.dumps(out, indent=2)}
</script>'''

def render_faq(faq_items):
    out = json.loads(json.dumps(FAQ_TEMPLATE))
    for question, answer in faq_items:
        out["mainEntity"].append({
            "@type": "Question",
            "name": question,
            "acceptedAnswer": {
                "@type": "Answer",
                "text": answer
            }
        })
    return f'''<script type="application/ld+json">
{json.dumps(out, indent=2)}
</script>'''

# 用法:
# 1. 把 meta 字典准备好（标题、描述、URL、关键词）
# 2. 把每个文章的 FAQ Q&A 准备好
# 3. 渲染后嵌入文章 HTML
```

把这脚本存到 `tools/generate_schema.py`，你们技术团队可以直接用。
