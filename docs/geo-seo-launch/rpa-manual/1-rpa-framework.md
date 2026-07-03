# 1. RPA Framework - 浏览器自动化基础框架

> 本文档定义"AI Agent 怎么启动浏览器、登录账号、throttle、做 screenshot、保存 log、handle pause"。
> 后续 4 个 publish 文档都基于这些 foundations。

---

## 1.1 Browser Stack 假设

```yaml
默认设置:
  engine: chromium
  headless: false              # 必须可见窗口,以便截图;被认作"真人"
  viewport: {width: 1440, height: 900}
  user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

个性化的 user_agent: 每个账号配一个不同的 PC 环境(见 1.4 fingerprint)

session:
  storage_state_path: ./state/storage/{account_id}.json
  cookies 持续持久化,localStorage 持续持久化
  不允许:每次重新登录(每次重新登录都是登录信号)
```

## 1.2 启动时的 6 步流程

```javascript
// tools/launch-daemon.js

const { chromium } = require('playwright');
const fs = require('fs');

async function launchAgent(accountConfig) {
  // Step 1: 检查 pause flag
  if (checkPauseFlag()) {
    log.info('system paused, exiting');
    process.exit(0);
  }

  // Step 2: 加载账号 fingerprint 配置
  const fingerprint = JSON.parse(fs.readFileSync('./config/browser-fingerprint.json'))[accountConfig.id];

  // Step 3: 启动 chromium with fingerprint
  const browser = await chromium.launch({
    headless: false,
    args: fingerprint.chromiumArgs,
  });

  // Step 4: 创建 context with storage_state (避免重新登录)
  const context = await browser.newContext({
    storageState: `./state/storage/${accountConfig.id}.json`,
    userAgent: fingerprint.userAgent,
    viewport: fingerprint.viewport,
    locale: 'en-US',
    timezoneId: fingerprint.timezone,
  });

  // Step 5: 防指纹
  await context.addInitScript((fingerprint) => {
    Object.defineProperty(navigator, 'webdriver', { get: () => false });
    Object.defineProperty(navigator, 'languages', { get: () => ['en-US', 'en'] });
    Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3, 4, 5] });
    Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });
    Object.defineProperty(window.screen, 'width', { get: () => fingerprint.viewport.width });
    Object.defineProperty(window.screen, 'height', { get: () => fingerprint.viewport.height });
    Object.defineProperty(window.screen, 'colorDepth', { get: () => 24 });
    Object.defineProperty(window, 'chrome', { get: () => ({ runtime: {} }) });
  }, fingerprint);

  // Step 6: 启动 page,执行任务列表
  const page = await context.newPage();
  return { browser, context, page };
}
```

## 1.3 State Management (核心)

### 1.3.1 quota.json

```json
{
  "platforms": {
    "linkedin-david-loan": {
      "last_publish_at": "2026-07-01T15:30:00Z",
      "publishes_in_24h": 1,
      "last_comment_at": "2026-07-01T17:45:00Z",
      "comments_in_72h": 1
    },
    "reddit-david-loan": {
      "last_publish_at": null,
      "publishes_in_24h": 0,
      "sub_post_history": {
        "realestateinvesting": ["2026-07-15"]
      }
    }
  }
}
```

**规则:如果 publishes_in_24h >= 1,跳过今天任何 publish 动作。**

### 1.3.2 pause.json

```json
{
  "paused": false,
  "reason": null,
  "paused_at": null,
  "paused_until": null
}
```

**如果有任何平台收到邮件警告 -> 立即写入暂停 = paused_until = now + 30 天**

### 1.3.3 warnings.json

```json
{
  "warnings": [
    {
      "platform": "linkedin-david-loan",
      "type": "auto_restriction",
      "message_text": "We've restricted your account...",
      "received_at": "2026-07-05T08:30:00Z",
      "action": "system_paused"
    }
  ]
}
```

**任何警告 trigger system_paused = true, forever rule**

### 1.3.4 content-status.json

```json
{
  "articles": {
    "loaninca.com/california-dscr-loans-broker-tips": {
      "status": "published",
      "platforms": {
        "medium": "published",
        "linkedin": "pending",
        "quora": "pending",
        "reddit": "pending"
      },
      "last_publish_attempt": "2026-07-08T09:30:00Z"
    }
  }
}
```

## 1.4 Fingerprint 文件 (核心防指纹)

```json
{
  "linkedin-david-loan": {
    "chromiumArgs": [
      "--disable-blink-features=AutomationControlled",
      "--disable-features=IsolateOrigins,site-per-process",
      "--window-size=1440,900"
    ],
    "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "viewport": {"width": 1440, "height": 900},
    "timezone": "America/Los_Angeles",
    "webgl": "Intel(R) UHD Graphics 620",
    "noise_capture": false,
    "webrtc_mask": true
  },
  "reddit-david-loan": {
    "chromiumArgs": ["--disable-blink-features=AutomationControlled"],
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "viewport": {"width": 1680, "height": 1050},
    "timezone": "America/Los_Angeles"
  }
}
```

**每个账号的 fingerprint 必须不同**——避免被关联。

## 1.5 Screenshot 规则

```javascript
async function snap(page, platform, action) {
  const path = `./screenshots/${new Date().toISOString().split('T')[0]}/${platform}/${action}-${Date.now()}.png`;
  await page.screenshot({ path, fullPage: false });
  return path;
}

// 强制:以下节点必须 screenshot
// 1. 每个平台 publish 按钮按下前
// 2. 每个平台 publish 完成后
// 3. 检测到任何错误 (红色 toast / error / warning)
// 4. 任何 rate-limit 触发
```

## 1.6 Throttle 策略

```javascript
async function throttle(action = 'publish') {
  const minDelayMs = {
    'publish': 25 * 60 * 1000,         // 25 minutes between publishes
    'comment': 4 * 60 * 60 * 1000,     // 4 hours between comments
    'like': 60 * 1000,                  // 1 minute between likes
    'navigation': 3 * 1000,             // 3 seconds between page loads
  };

  const wait = Math.floor(Math.random() * minDelayMs[action] * 0.5) + minDelayMs[action] * 0.5;
  log.info(`throttle ${action} for ${wait}ms`);
  await sleep(wait);
}
```

**为什么用 random interval**——避免固定时序被识别。

## 1.7 Rate Limiting (来自各平台 quota)

| 平台 | publishes/24h | comments/72h | sub post 间隔 |
|------|--------------|--------------|---------------|
| LinkedIn | 1 | 2 | 不适用 |
| Medium | 2 | 不适用 | 不适用 |
| Reddit | 1 | 2 | 14 天 |
| Quora | 2 | 不适用 | 不适用 |
| Twitter (可选) | 5 | 10 | 不适用 |

## 1.8 Pause 触发规则 (自动 + 手动)

### 自动 trigger
- 任意 platform email warning
- 任意 platform client-side warning toast
- 任意 2FA prompt
- 任意"限制" / "审核" / "限制账户"关键词检测
- 任意平台 IP 冲突提示

### 手动 trigger
- human 修改 `state/pause.json: paused = true`
- 暂停期间 daemon 仅空跑,不做任何 side effect

## 1.9 Critical 错误处理 (don't panic)

```javascript
const ERROR_HANDLERS = {
  '2FA_required': () => {
    triggerPause('2FA detected, manual reset required');
  },
  'captcha': () => {
    triggerPause('captcha detected, manual intervention required');
  },
  'account_restricted': () => {
    triggerPause('account restricted, manual reset required');
  },
  'rate_limited': () => {
    log.warn('rate limited, will retry in 24h');
  },
  'network_error': () => {
    log.warn('network error, will retry');
  },
  'popup_unexpected': () => {
    snap(page, platform, 'unexpected-popup');
    triggerPause('unexpected UI element, manual review required');
  }
};

async function detectError(page) {
  const text = await page.content();
  for (const [key, handler] of Object.entries(ERROR_HANDLERS)) {
    if (matchError(text, key)) {
      handler();
      return true;
    }
  }
  return false;
}

function matchError(content, errorType) {
  const patterns = {
    '2FA_required': /verification code|two-step|enter.{0,20}code/i,
    'captcha': /captcha|prove.{0,20}human|robot/i,
    'account_restricted': /restricted|locked|suspended|limited/i,
    'rate_limited': /try again later|too many requests|slow down/i
  };
  return patterns[errorType].test(content);
}
```

## 1.10 Log Format

每行 JSONL: `state/log/{date}.jsonl`

```json
{"ts":"2026-07-08T09:30:00Z","action":"publish","platform":"linkedin-david-loan","status":"ok","article":"loaninca.com/california-dscr-loans-broker-tips","duration_ms":12453,"screenshot":"./screenshots/2026-07-08/linkedin/publish-1720432200.png"}
{"ts":"2026-07-08T09:31:30Z","action":"comment","platform":"reddit-david-loan","status":"skipped","reason":"quota_limit_72h","comment_id":null}
{"ts":"2026-07-08T09:35:00Z","action":"throttle","action_to":"publish","wait_ms":1500000}
```

## 1.11 Cleanup / GC

```javascript
// 每 7 天清理:
// - screenshots 超过 30 天 -> 删除
// - log 超过 90 天 -> 压缩存档
// - storage_state_quota 过期 -> 保留

async function cleanup() {
  const screenshotsDir = './screenshots';
  // 删除超过 30 天的文件
  exec(`find ${screenshotsDir} -type f -mtime +30 -delete`);
}
```

## 1.12 启动 + 关停

```bash
# 启动(后台)
$ nohup node tools/launch-daemon.js > state/daemon.log 2>&1 &

# 状态查看
$ tail -f state/log/$(date +%Y-%m-%d).jsonl | jq

# 暂停所有自动化
$ echo '{"paused": true, "reason": "manual", "paused_at": "...", "paused_until": null}' > state/pause.json

# 解除暂停
$ echo '{"paused": false, "reason": null, "paused_at": null, "paused_until": null}' > state/pause.json
```

## 1.13 不要做这些事

❌ **不要使用任何官方 API** (LinkedIn Marketing API、Reddit OAuth)——违反 ToS 会立刻 ban
❌ **不要共享 IP/vpn**——12 个账号用不同的 residential proxy (Bright Data / Smartproxy)
❌ **不要用 datacenter IP**——平台百分百识破
❌ **不要使用 Capmonster / 2Captcha / Anti-Captcha**——绕过 captcha = 永久 ban
❌ **不要账号间转账 / 直接关联**——3 个站账号独立 email、独立 fingerprint

详细 publish 流程: `3-medium-publish.md` / `4-linkedin-publish.md` / `5-quora-reddit-publish.md`
