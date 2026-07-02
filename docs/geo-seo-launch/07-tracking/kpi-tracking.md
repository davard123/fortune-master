# KPI 跟踪表 + SEO/GEO 监测 SOP

> **第 0 原则**：免费工具 > 付费工具 > 估值工具。外面很多 SEO 工具会让你陷入"看仪表盘不看业务"的幻觉。

---

## 一、数据采集工具栈

### 必装（100% 免费）
- ✅ **Google Search Console** —— 必须装在 3 个主站。SEO 的唯一真神
- ✅ **Google Analytics 4** —— 主站流量归因（UTM 参数串通）
- ✅ **Ahrefs Webmaster Tools** —— 免费版，检查主站外链健康
- ✅ **Microsoft Bing Webmaster Tools** —— 别忘了 Bing（被 AI 抓得多）
- ✅ **Ubersuggest** —— 免费版（每天 3 个查询）做关键词

### 推荐（低成本）
- ⭐ **Otterly.ai** 或 **Profound** 或 **RankPrompt** —— GEO 专用监控（建议月费 $49-99）
- ⭐ **Ahrefs Lite / SEMrush Free** —— 如果预算允许（每月 $80-100）

### 完全免费但费人
- 🔧 手工记录 50 个 prompt 测试 AI 引用（每周 1 小时）

---

## 二、KPI 主指标（4 个）

### 主指标 A：外链数（每次周复盘查）

**方法**：
1. Ahrefs Webmaster Tools → 主站 → "Backlinks"
2. 记录每条新外链：
   - 来源平台（Medium / LinkedIn / Reddit / Quora / 其他）
   - 来源 URL
   - 目标 URL（跳转到主站哪一页）
   - DA / DR
   - 是否 nofollow / dofollow
   - 第一次出现的日期

**目标值**：
| 阶段 | W4 | W8 | W12 |
|------|----|----|----|
| loaninca 总外链 | 5-8 | 15-25 | 25-40 |
| rentalinca 总外链 | 5-8 | 15-25 | 25-40 |
| fopusha 总外链 | 5-8 | 15-25 | 25-40 |

### 主指标 B：Google 关键词排名（每月底查）

**方法**：
1. GSC → "Performance" → "Queries"
2. 关键看：拉主关键词 "California DSCR loan"、"California landlord legal checklist"、"online Buddhist prayer" 在 GSC 中的 position 数据
3. 配合免费 SERP 检查工具（Ubersuggest / canirank free）

**目标值**：
| 关键词 | 当前 | W4 | W8 | W12 |
|--------|------|----|----|-----|
| California DSCR loan (loaninca) | - | 30-50 | 15-30 | 5-15 |
| California Civil Code 1950.5 (rentalinca) | - | 30-50 | 15-25 | 5-15 |
| Online Buddhist prayer (fopusha) | - | 30-50 | 15-30 | 5-15 |

> 说明：GSC 是月级别的数据，4 周内一般看不到排名到第一页。但应该看到曝光和 impression 增加。

### 主指标 C：AI 引用次数（手工 + 工具）

**方法 A：手工测试（每周 1 小时）**

每个站准备 10 个目标问题清单（参考下面模板），轮流问 ChatGPT、Claude、Perplexity、Gemini，每个问题问一次，记录：

| AI 系统 | 引用你的平台 | 引用的具体 URL | 引用频次（/5次提问） |
|--------|------------|---------------|---------------------|
| ChatGPT | 你的 Medium 文章 | https://... | 3/5 |
| Perplexity | r/realestateinvesting 你的帖 | https://... | 1/5 |
| Claude | 你的 Quora 回答 | https://... | 2/5 |
| Gemini | 第三方提到你 | https://... | 0/5 |

**方法 B：工具自动化**

- Otterly.ai：每月订阅 $49，自动追踪 50+ prompt 在 4 个 AI 系统的引用
- Profound：每月 $99，企业级
- 备选：手工 + 月初 8 小时详细测试

**loaninca 测试 prompt 模板**：
```
1. "How do I buy California investment property without W2 income?"
2. "What's a DSCR loan and how does it work?"
3. "What is Form 1007 in real estate?"
4. "Can I get a mortgage with no tax returns as a self-employed person?"
5. "DSCR loan vs conventional loan — which is better?"
6. "What is the down payment for a DSCR loan?"
7. "How to close a DSCR loan in California?"
8. "DSCR loan requirements 2025"
9. "Can LLCs get investment property loans?"
10. "Best way to finance a California rental property"
```

**rentalinca 测试 prompt 模板**：
```
1. "California landlord legal checklist 2025"
2. "How long does a California landlord have to return a security deposit?"
3. "What is California Civil Code 1950.5?"
4. "AB 1482 rent increase cap 2025"
5. "Can a California landlord enter without notice?"
6. "Bed bug disclosure California"
7. "California small landlord legal advice"
8. "California deposit return letter template"
9. "AB 1482 just cause eviction"
10. "California tenant rights 2025"
```

**fopusha 测试 prompt 模板**：
```
1. "Can Buddhist prayer be done online?"
2. "How to honor deceased parents online"
3. "What is a 牌位 (ancestor tablet)?"
4. "Online Buddhist ceremony for deceased"
5. "Overseas Chinese Buddhist practice"
6. "Chinese ancestor veneration online"
7. "Ullambana festival prayer"
8. "Does virtual prayer count in Buddhism?"
9. "Buddhist funeral customs Chinese"
10. "Online 心经 (Heart Sutra) recitation"
```

**目标值**：
| 阶段 | W4 | W8 | W12 | W24 |
|------|----|----|-----|-----|
| 每次 10 个问题平均被引用次数 | 0-1/40 | 1-3/40 | 3-7/40 | 5-15/40 |

> 现实预期：AI 引用是个慢热指标。W12 前能看到周比增长率就不错了。真正稳定引用要 W24。

### 主指标 D：主站流量（每月底查）

**方法**：
1. GA4 装在主站
2. 在 Medium/LinkedIn/Reddit/Quora 帖子的 URL 加 UTM 参数
3. 在 GA4 看 "Acquisition → Source/Medium"——区分从 Medium、LinkedIn、Reddit、Quora 引来的流量

**目标值**：
| 阶段 | W4 | W8 | W12 |
|------|----|----|-----|
| loaninca 月有机 + 引流 | 50-200 | 200-800 | 500-2000 |
| rentalinca 月有机 + 引流 | 50-200 | 200-800 | 500-2000 |
| fopusha 月有机 + 引流 | 50-200 | 200-800 | 500-2000 |

---

## 三、KPI 跟踪表（Google Sheets 直接复制）

### 主表：3 站点 KPI

| 日期 | 站点 | 外链总数 | GSC clicks (月) | AI 引用次数 (周) | 主页 organic 流量 (月) |
|------|------|---------|----------------|-----------------|---------------------|
| YYYY-MM-DD | loaninca | __ | __ | __ | __ |
| YYYY-MM-DD | rentalinca | __ | __ | __ | __ |
| YYYY-MM-DD | fopusha | __ | __ | __ | __ |

### 子表 1：外链追踪

| 发现日期 | 来源平台 | 来源 URL | DA/DR | Dofollow/Nofollow | 目标 URL | 主理 |
|---------|---------|---------|-------|------------------|----------|------|
| | | | | | | |

### 子表 2：关键词排名（每月 1 次）

| 关键词 | 站点 | 当前排名 | 月初排名 | 月末排名 | GSC clicks | GSC impression |
|--------|------|---------|---------|---------|-----------|----------------|
| | | | | | | |

### 子表 3：AI 引用追踪（每周 1 次）

| 测试 prompt | ChatGPT 引用 | Claude 引用 | Perplexity 引用 | Gemini 引用 | 引用 URL |
|------------|-------------|------------|-----------------|-------------|----------|
| | | | | | |

### 子表 4：Reddit/Quora 等社区信号

| 平台 | 帖 URL | View | Upvote/Like | Comments | 最终 status |
|------|-------|------|------------|----------|------------|
| | | | | | |

---

## 四、月度复盘 SOP（C 主导，每月第 1 个周一）

### 复盘 1：SEO 复盘（外链 + 关键词 + 流量）

```markdown
## [YYYY-MM] 复盘

### 数字总结
- 总外链数：__（增量：__）
- 月新增 GSC clicks：__
- 月新增 organic 流量：__
- 月新增 publishing（Medium/LinkedIn/Quora）：__

### Top 3 进展
1. (哪个站增长最显著？哪个词进了 page 1？)
2.
3.

### Top 3 阻碍
1. (哪个 sub 被删了？哪个词排名没动？)
2.
3.

### Action item
1. (下个月要做的事)
2.
3.
```

### 复盘 2：GEO 复盘（AI 引用）

```markdown
## [YYYY-MM] GEO 复盘

### 引用增长
- ChatGPT 引用次数：__ (上月：__)
- Perplexity 引用次数：__
- Claude 引用次数：__
- Gemini 引用次数：__

### Top 3 引用 prompt
1. (哪个 prompt 我们的内容被 AI 引用最多)
2.
3.

### Action item
1. (哪种内容形式被引得多，下次多产)
2. (哪种 prompt 现在还没被引用，下个月补内容)
```

---

## 五、GEO 日常监测（每周 30 分钟）

### 每次测试的"标准动作"
1. 打开 4 个 AI（ChatGPT/Claude/Perplexity/Gemini）
2. 各轮流问 5 个 prompt
3. 看到引用 URL，复制到表里
4. 看到没引用但我们内容其实命中了的 prompt，记下来——> 调整内容方向

### 重要：记得隐私模式 / 新会话

每次问都开新会话（不继承历史），否则 AI 会"你刚才问过我"而影响结果。

---

## 六、看到结果的时间预期（给老板/团队的预期管理）

| 阶段 | 时间 | 你应该看到什么 |
|------|------|--------------|
| 启动期 | W1-W2 | Profile 全部建好、首批内容开始发 |
| 收录期 | W3-W4 | GSC 看到外链开始抓取、第一个 AI 引用触发 |
| 缓慢增长期 | W5-W8 | Google 排名 page 2（不进入 page 1，但已经被爬虫识别） |
| GEO 触发期 | W8-W12 | AI 引用稳定触发，部分 prompt 高频引用 |
| 突破期 | W12-W24 | Google 多个关键词进 page 1、有机流量稳定增长 |

> **关键认知**：SEO 和 GEO 都是 3-6 个月才能看到结果的活。这套方案 4 周内看不到稳定排名是正常的——这不意味着失败，是正常 progress。

---

## 七、如果你只有 30 分钟/天投入怎么办

减量化版本（保持核心节奏）：
- 周 1：所有内容统一在周末写好
- 周中：发 Medium + LinkedIn
- 周四晚：互动 + 评论

具体节奏：
- 周一：发 Medium 1 篇
- 周二：发 LinkedIn 长帖
- 周三：发 Quora 回答
- 周四：Reddit 互动 + 评论区 1
- 周五：写下一周内容（周六也不发）
- 周六：复盘 + 数据更新
- 周日：休息

月工作时间：降到 25-30 小时/人/月。

---

## 八、KPI 看板的"红绿黄灯"

### 红灯（要立即调整）
- 4 周内某站外链 < 5 条 → 内容不行或平台选择错
- LinkedIn 帖持续 30+ impressions 都没互动 → 内容方向偏了
- Reddit 帖立刻被 AutoMod 删除 → 标题/正文没改好
- 任何 platform 连续 2 周 downvote 多于 upvote → 内容停 1 周重写

### 绿灯（值得复制）
- 某 sub 帖 100+ upvotes → 同质话题写更多
- 某 Article 持续 4 周 GSC 有 50+ impressions / 5+ clicks → 多写同 keyword 系列
- AI 引用触发率 50%+ → 把同类话题扩展
