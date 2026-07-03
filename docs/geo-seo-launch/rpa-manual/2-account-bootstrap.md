# 2. Account Bootstrap - 12 个账号的注册 + Profile 填写

> 这是 W0-W1 的任务 —— AI Agent 必须在 human 完成注册 phone verification 后,自动把 Profile 文案填好。
>
> **重要: 实际账号注册 = HUMAN 必做**
> - LinkedIn 必填手机验证码
> - Medium 必填 email 验证
> - Reddit 必填 email 验证
> - Quora 必填 email 验证
>
> 本文档假设 human 已经注册完所有 12 个账号,且把 session cookies inject 到 `./state/storage/{account_id}.json`

---

## 2.1 账号清单

```
linkedin-david-loan       → loaninca.com
linkedin-david-rent       → rentalinca.com
linkedin-david-buddha     → fopusha.com
medium-david-loan         → loaninca.com + Publication "loaninca"
medium-david-rent         → rentalinca.com + Publication "rentalinca"
medium-david-buddha       → fopusha.com + Publication "fopusha"
reddit-david-loan         → loaninca.com  (r/realestateinvesting)
reddit-david-rent         → rentalinca.com (r/Landlord)
reddit-david-buddha       → fopusha.com   (r/Buddhism)
quora-david-loan          → loaninca.com
quora-david-rent          → rentalinca.com
quora-david-buddha        → fopusha.com
```

## 2.2 Session State 注入流程 (human 必做)

每账号 human 登录后,导出 cookies/localStorage 到 JSON:

```javascript
// human 在浏览器 console 跑:
copy(JSON.stringify(await cookieStore.getAll()), '--PASTE-INTO-CHAT--');
```

或者用 Playwright:

```javascript
// human 操作
await page.context().storageState({ path: './state/storage/linkedin-david-loan.json' });
```

## 2.3 Profile 填写 (AI Agent 自动)

### Step 1: LinkedIn Profile 填写 (3 个账号)

```javascript
// tools/scripts/linkedin-bootstrap.js

async function bootstrapLinkedInProfile(accountId) {
  // Step 1.1: 检查 quota
  if (!checkBootstrapQuota(accountId, 'linkedin', 1)) {
    log.info(`${accountId} already bootstrapped`);
    return;
  }

  // Step 1.2: 启动浏览器(每个 account 不同 fingerprint)
  const { page, context } = await launchAgent(getAccountConfig(accountId));
  await throttle('navigation');

  // Step 1.3: 进 LinkedIn /me/edit
  await page.goto('https://www.linkedin.com/in/me/edit/');
  await page.waitForSelector('input[id="first-name"]', { timeout: 30000 });
  await snap(page, 'linkedin', 'profile-edit-open');

  // Step 1.4: 获取对应 site 的 Profile JSON
  const profileData = getProfileJSON(accountId);
  // { headline, about, current_position_title, current_position_company, ... }

  // Step 1.5: 填 Headline
  await page.fill('input[id="headline"]', profileData.headline);
  await sleep(2000);

  // Step 1.6: 填 About (用 contenteditable div)
  await page.click('div[aria-label="About"]');
  await sleep(1000);
  // 找到 contenteditable 内部 p
  await page.evaluate((html) => {
    const editor = document.querySelector('div[aria-label="About"] .ql-editor');
    if (editor) {
      editor.innerHTML = html;
    }
  }, profileData.about_html);
  await sleep(2000);

  // Step 1.7: Experience
  await page.click('button[aria-label="Add experience"]');
  await page.waitForSelector('input[id="title"]', { timeout: 10000 });
  await page.fill('input[id="title"]', profileData.current_position_title);
  await page.fill('input[id="company-name-autocomplete"]', profileData.current_position_company);
  await sleep(3000);
  await page.click(`button:has-text("${profileData.current_position_company}")`);
  await page.fill('textarea[id="description"]', profileData.experience_description);

  // Step 1.8: 提交 experience
  await page.click('button[aria-label="Save"]');
  await sleep(2000);
  await snap(page, 'linkedin', 'experience-added');

  // Step 1.9: 跳到 Featured 编辑页
  await page.goto(`https://www.linkedin.com/in/me/edit/featured`);

  // 1.10: Featured (推迟到 W3 才有内容链接,这里只放主站 URL)
  // - 第一次 publish 文章后才有 Featured media
  // 跳过这个 step,留 W3 再执行

  // 1.11: Save All
  await page.click('button[type="submit"]:has-text("Save")');
  await sleep(3000);
  await snap(page, 'linkedin', 'profile-saved');

  // 1.12: 写 quota
  writeBootstrapQuota(accountId, 'linkedin');

  // 1.13: log
  log.write({
    action: 'bootstrap-linkedin',
    account: accountId,
    status: 'ok'
  });
}
```

### Step 2: Medium Profile + Publication

```javascript
// tools/scripts/medium-bootstrap.js

async function bootstrapMedium(accountId) {
  const { page, context } = await launchAgent(getAccountConfig(accountId));
  await throttle('navigation');

  await page.goto('https://medium.com/me/settings');
  await page.waitForSelector('input[id="profileNameInput"]', { timeout: 30000 });

  const data = getMediumConfig(accountId);

  // 2.1: Display name
  await page.fill('input[id="profileNameInput"]', data.display_name);
  await sleep(2000);

  // 2.2: Bio
  await page.fill('textarea[id="bioInput"]', data.bio);
  await sleep(2000);
  await snap(page, 'medium', 'profile-filling');

  // 2.3: Save
  await page.click('button:has-text("Save")');
  await sleep(3000);

  // 2.4: 创建 Publication
  await page.goto('https://medium.com/pubs/create');
  await page.waitForSelector('input[placeholder*="publication"]', { timeout: 10000 });

  await page.fill('input[placeholder*="publication"]', data.publication_name);
  await sleep(2000);
  await page.fill('textarea[placeholder*="Tagline"]', data.publication_tagline);

  // 2.5: 描述
  const descEditor = await page.locator('div[contenteditable="true"]').first();
  await descEditor.click();
  await sleep(500);
  await page.keyboard.type(data.publication_description);
  await sleep(2000);
  await snap(page, 'medium', 'publication-creating');

  // 2.6: Submit
  await page.click('button[type="submit"]');
  await sleep(5000);
  await snap(page, 'medium', 'publication-created');

  writeBootstrapQuota(accountId, 'medium');
  log.write({
    action: 'bootstrap-medium',
    account: accountId,
    status: 'ok',
    publication_url: page.url()
  });
}
```

### Step 3: Reddit 账号"about" + flair

```javascript
// tools/scripts/reddit-bootstrap.js

async function bootstrapReddit(accountId) {
  const subTarget = getRedditSub(accountId);
  const { page, context } = await launchAgent(getAccountConfig(accountId));
  await throttle('navigation');

  // 3.1: 进 reddit.com/user/{username}/about
  const username = getRedditUsername(accountId);
  await page.goto(`https://www.reddit.com/user/${username}/`);
  await page.waitForSelector('button[id*="USER_PROFILE"]', { timeout: 30000 });

  // 3.2: 改 sidebar description
  await page.goto(`https://www.reddit.com/user/${username}/edit`);
  await sleep(5000);
  await page.waitForSelector('textarea[id="id_body"]', { timeout: 10000 });
  await page.fill('textarea[id="id_body"]', redditProfileData.about);
  await page.click('button[type="submit"]');
  await sleep(3000);
  await snap(page, 'reddit', 'sidebar-saved');

  // 3.3: 蹲到目标 sub, 设 flair (能设的 sub only)
  // [这一步很重要,某些 sub 是 Not Applicable]
  await page.goto(`https://www.reddit.com/r/${subTarget}/`);
  await sleep(5000);

  // 跳过 AutoMod 触发的 sub
  const restrictedSubs = ['Buddhism', 'realestateinvesting', 'Landlord'];
  // 每个 sub 限制不同

  // 3.4: 假装只是"查看", 跟 sub 互动 5-10 个赞 (这是 W1 silent phase 的一部分,见 framework.md)
  await warmupSubInteraction(page, subTarget, 5);

  writeBootstrapQuota(accountId, 'reddit');
  log.write({
    action: 'bootstrap-reddit',
    account: accountId,
    status: 'ok'
  });
}

// 关键: 不能做任何 comment during W1,W1 只 read + upvote
async function warmupSubInteraction(page, subName, count) {
  await page.goto(`https://www.reddit.com/r/${subName}/hot/`);
  await sleep(3000);

  const cards = await page.locator('div[data-testid="post-container"]').all();
  for (let i = 0; i < Math.min(count, cards.length); i++) {
    const upBtn = cards[i].locator('button[aria-label*="upvote"]').first();
    if (await upBtn.isVisible()) {
      await upBtn.click();
      await sleep(800 + Math.random() * 1500); // 随机间隔 0.8s-2.3s
    }
  }
}
```

### Step 4: Quora Profile + Space

```javascript
// tools/scripts/quora-bootstrap.js

async function bootstrapQuora(accountId) {
  const { page, context } = await launchAgent(getAccountConfig(accountId));

  // 4.1: Profile
  await page.goto('https://www.quora.com/settings/profile');
  await page.waitForSelector('input[id="profile_name"]', { timeout: 30000 });
  await snap(page, 'quora', 'profile-edit');

  await page.fill('input[id="profile_name"]', quoraProfileData.display_name);
  await page.fill('textarea[class*="profile_bio"]', quoraProfileData.bio);
  await page.fill('input[class*="credential"]', quoraProfileData.credentials[0]);
  await sleep(2000);
  await page.click('button:has-text("Save")');
  await sleep(3000);

  // 4.2: 关注目标 Spaces (readonly follow, 无 publish)
  const targetSpaces = getQuoraSpaces(accountId);
  for (const space of targetSpaces) {
    await page.goto(`https://www.quora.com/${space}`);
    await sleep(3000);

    // Find "Follow" button
    const followBtn = page.locator('button:has-text("Follow")').first();
    if (await followBtn.isVisible()) {
      await followBtn.click();
      await sleep(2000 + Math.random() * 2000);
    }
  }

  // 4.3: Create Space
  await page.goto('https://www.quora.com/spaces/create');
  await page.waitForSelector('input[placeholder*="space name"]', { timeout: 30000 });
  await page.fill('input[placeholder*="space name"]', quoraSpaceData.space_name);
  await page.fill('textarea[placeholder*="Describe your space"]', quoraSpaceData.space_description);
  await sleep(2000);
  await page.click('button[type="submit"]');
  await sleep(5000);
  await snap(page, 'quora', 'space-created');

  writeBootstrapQuota(accountId, 'quora');
  log.write({
    action: 'bootstrap-quora',
    account: accountId,
    status: 'ok'
  });
}
```

## 2.4 顺序执行

```bash
# 12 账号,顺序 bootstrap

$ for account in linkedin-david-loan linkedin-david-rent linkedin-david-buddha medium-david-loan medium-david-rent medium-david-buddha reddit-david-loan reddit-david-rent reddit-david-buddha quora-david-loan quora-david-rent quora-david-buddha; do
    case "$account" in
      linkedin-*) node tools/scripts/linkedin-bootstrap.js --account=$account ;;
      medium-*) node tools/scripts/medium-bootstrap.js --account=$account ;;
      reddit-*) node tools/scripts/reddit-bootstrap.js --account=$account ;;
      quora-*) node tools/scripts/quora-bootstrap.js --account=$account ;;
    esac
    sleep 30
done
```

**每个账号间间隔 ≥ 30 秒**——错开 fingerprint 时间戳,避免关联。

## 2.5 Bootstrap 失败处理

如果任一 bootstrap step 失败:

```javascript
async function bootstrapWithRetry(accountId, fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await fn(accountId);
      log.write({ account: accountId, retry: i, status: 'ok' });
      return true;
    } catch (e) {
      if (i === maxRetries - 1) {
        triggerPause(`bootstrap fail: ${accountId} ${e.message}`);
        return false;
      }
      log.warn(`retry ${i+1}/${maxRetries} for ${accountId}: ${e.message}`);
      await sleep(60 * 1000 * (i + 1));  // 1min, 2min, 3min
    }
  }
}
```

## 2.6 Bootstrap 完成后的检查

```bash
$ node tools/scripts/check-bootstrap.js

# 输出:
# ✓ linkedin-david-loan: profile complete, 100% filled
# ✓ linkedin-david-rent: profile complete
# ✓ linkedin-david-buddha: profile complete
# ✓ medium-david-loan: Publication "loaninca" created at /loaninca-california-investment-property-lending
# ✓ medium-david-rent: Publication "rentalinca" created
# ✓ medium-david-buddha: Publication "fopusha" created
# ✓ reddit-david-loan: profile complete, 5 warmup upvotes in r/realestateinvesting
# ✓ reddit-david-rent: profile complete
# ✓ reddit-david-buddha: profile complete
# ✓ quora-david-loan: profile + Space "California DSCR..." created
# ✓ quora-david-rent: profile + Space created
# ✓ quora-david-buddha: profile + Space created

# Required next steps:
# → 等待 14 天(W2-W3 静默期)
# → W3 后可以开始 publish(见 3-medium-publish.md)
```

Bootstrap 完成后,进入 W1 silent phase。

## 2.7 Silent Phase 自动化 (W1-W2)

W1-W2 期间,12 个账号每个每天做:

- 1. 读取主页(3-5 帖子 view)
- 2. 点赞 1-3 个帖子
- 3. **不评论** (W1 都不能)
- 4. **不发表** (W1 都不能)

```javascript
// tools/scripts/silent-phase-daily.js

const silentAccounts = [
  'linkedin-david-loan', 'linkedin-david-rent', 'linkedin-david-buddha',
  'medium-david-loan', 'medium-david-rent', 'medium-david-buddha',
  'reddit-david-loan', 'reddit-david-rent', 'reddit-david-buddha',
  'quora-david-loan', 'quora-david-rent', 'quora-david-buddha'
];

async function silentPhaseDaily() {
  for (const accountId of silentAccounts) {
    await throttle('navigation');
    const { page } = await launchAgent(getAccountConfig(accountId));

    // 仅 reddit 与 quora 真正"用"silent read;linkedin/medium 无 sub 行为,跳过
    if (!['reddit', 'quora'].some(s => accountId.startsWith(s))) {
      log.write({ account: accountId, action: 'silent_skip', reason: 'no_subs_to_view' });
      continue;
    }

    const target = getTargetSub(accountId);
    await page.goto(`https://www.${accountId.startsWith('reddit') ? 'reddit.com/r/' + target : 'quora.com'}/${target || ''}`);
    await sleep(3000 + Math.random() * 5000);

    // Upvote 1-3 个
    const posts = await page.locator('article, div[data-testid="post-container"]').all();
    const targetCount = Math.floor(Math.random() * 3) + 1;
    for (let i = 0; i < Math.min(targetCount, posts.length); i++) {
      const upBtn = posts[i].locator('button[aria-label*="upvote"]').first();
      if (await upBtn.isVisible()) {
        await upBtn.click();
        await sleep(1500 + Math.random() * 2000);
      }
    }

    await snap(page, accountId.split('-')[0], 'silent-day-end');
    log.write({ account: accountId, action: 'silent_upvotes', count: targetCount });
    await sleep(60 * 1000);  // 1 min between accounts
  }
}
```

**silent phase duration = 14 days**——W3 start 可以 active。
