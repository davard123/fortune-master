// supabase/functions/_shared/cors.ts
// 共享的 CORS + 错误响应 helper.
// 注意：Edge Function 之间通过相对路径 import, 例如
//   import { buildCorsHeaders, jsonResponse } from '../_shared/cors.ts';

// 允许的来源. 部署到 supabase 后, 真实域名再加:
//   - fortune-master.pages.dev  (Cloudflare Pages preview)
//   - *.fortunemaster.app       (production custom domain, future)
// 开发期:
const ALLOWED_ORIGINS: readonly string[] = [
  'https://fortune-master.pages.dev',
  'https://fortunemaster.app',
  'https://www.fortunemaster.app',
  'http://localhost:3000',   // flutter run -d chrome --web-port=3000
  'http://localhost:8080',   // flutter run -d chrome --web-port=8080
  'http://localhost:54321',  // supabase functions serve 本地
];

const DEFAULT_ORIGIN = 'https://fortune-master.pages.dev';

const BASE_HEADERS: Record<string, string> = {
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Max-Age': '86400',
  'Vary': 'Origin',
  'Content-Type': 'application/json',
};

/**
 * 依据 Origin 头返回一个反映实际 origin 的 CORS 头集合.
 * 没有 Origin (server-to-server 调用) 或 origin 不在白名单 → 默认 origin.
 */
export function buildCorsHeaders(req: Request): Record<string, string> {
  const origin = req.headers.get('Origin') ?? '';
  const allowed = ALLOWED_ORIGINS.includes(origin) ? origin : DEFAULT_ORIGIN;
  return {
    ...BASE_HEADERS,
    'Access-Control-Allow-Origin': allowed,
  };
}

/** 处理 OPTIONS 预检 */
export function handleCorsPreflight(req: Request): Response {
  return new Response('ok', { headers: buildCorsHeaders(req) });
}

/** 通用 JSON 响应 */
export function jsonResponse(
  req: Request,
  body: unknown,
  status = 200,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: buildCorsHeaders(req),
  });
}
