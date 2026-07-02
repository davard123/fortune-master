# interpret Edge Function

LLM-driven interpretation of divination charts (Bazi / Tarot / Qimen / Ziwei / I Ching).

POST `/functions/v1/interpret`

## Request

```json
{
  "system": "bazi" | "tarot" | "qimen" | "ziwei" | "iching",
  "tier":   "brief" | "detailed",
  "locale": "en" | "zh-CN",
  "chart":  { /* full chart_data returned by chart-bazi/tarot/qimen */ }
}
```

## Response

```json
{
  "interpretation": "...",
  "model": "github/gpt-4o-mini",
  "locale": "en",
  "tier":   "brief",
  "system": "bazi",
  "charsLength": 318
}
```

Error envelope: `{ "error": "..." }` with appropriate HTTP status (400 / 500 / 502 / 503).

## Configuration

All secrets are set on the Supabase side, never in source:

```bash
supabase secrets set \
  FREELLMAPI_URL=http://localhost:3001/v1 \
  FREELLMAPI_KEY=freellmapi-xxxxxxxx \
  IS_PUBLIC_RELEASE=false \
  --project-ref xjvoqpijrpjmgqkqwhqd
```

Environment variables read at runtime (any non-empty value wins):

| Priority | Variable | Purpose |
|---|---|---|
| 1 | `FREELLMAPI_URL` | Base URL for OpenAI-compatible endpoint |
| 2 | `LLM_BASE_URL` | Phase 2 fallback (e.g. `https://api.deepseek.com/v1`) |
| 1 | `FREELLMAPI_KEY` | API key for the above endpoint |
| 2 | `LLM_API_KEY` | Phase 2 fallback key |
| 3 | `DEEPSEEK_API_KEY` | Legacy alias (still accepted if above are unset) |
| — | `IS_PUBLIC_RELEASE` | `true` blocks localhost endpoints in production |

## Model routing (FreeLLMAPI provider paths)

| Tier | Locale | Model |
|---|---|---|
| brief | zh-CN | `zhipu/glm-4.5` |
| brief | en | `github/gpt-4o-mini` |
| detailed | zh-CN | `cloudflare/kimi-k2` |
| detailed | en | `github/gpt-4.1` |

## Switching to DeepSeek (Phase 2 — zero code change)

```bash
supabase secrets unset FREELLMAPI_URL FREELLMAPI_KEY --project-ref xjvoqpijrpjmgqkqwhqd
supabase secrets set \
  LLM_BASE_URL=https://api.deepseek.com/v1 \
  LLM_API_KEY=<deepseek-key> \
  IS_PUBLIC_RELEASE=true \
  --project-ref xjvoqpijrpjmgqkqwhqd
```

FreeLLMAPI binds `127.0.0.1` by default — it is **not reachable** from Supabase cloud runtime. Either expose it via a Cloudflare Tunnel with auth, or switch to a public API (DeepSeek / OpenAI / Anthropic via OpenAI-compatible proxy) before going public.

## Safety guard

When `IS_PUBLIC_RELEASE=true` and `FREELLMAPI_URL` / `LLM_BASE_URL` still points to `localhost`, the function refuses with HTTP 503. This prevents accidentally exposing a dev-only LLM proxy to the public.

## Local testing

```bash
# Start FreeLLMAPI Docker locally
docker compose up -d  # see https://github.com/tashfeenahmed/freellmapi

# Run function locally
supabase functions serve interpret --env-file ./supabase/functions/interpret/.env.example --no-verify-jwt
# Function runs on http://localhost:54321/functions/v1/interpret

# Probe with curl
curl -s -X POST "http://localhost:54321/functions/v1/interpret" \
  -H "Content-Type: application/json" \
  -d '{
    "system":"bazi",
    "tier":"brief",
    "locale":"en",
    "chart":{"dayMaster":"Geng","fourPillars":{"year":{"stem":"Geng","branch":"Wu"}}}
  }' | jq .
```

## Prompt design

- **Tier `brief`**: ≤200 words, 3 sections (personality / current trend / action suggestion)
- **Tier `detailed`**: 800-1500 words, 6 dimensions (personality / career / wealth / love / health / annual trend)
- All prompts force the model to (a) reference chart data, (b) include a non-professional-advice disclaimer, (c) avoid deterministic predictions
- `chart` JSON is truncated to 6000 chars before being injected to bound prompt size
