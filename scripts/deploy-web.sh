#!/usr/bin/env bash
# 部署 Flutter Web 到 Cloudflare Pages (fortune.fopusha.com)
# 用法: bash scripts/deploy-web.sh
#
# 为什么有 cache-bust 步骤:
#   Flutter web 产物 (flutter_bootstrap.js / main.dart.js) URL 不带内容哈希。
#   历史上 _headers 曾把它们设为 1 年 immutable, Cloudflare 边缘至今可能还留有
#   旧缓存条目 (无参数 URL 键)。给入口链路加 ?v=<时间戳> 使每次部署产生全新
#   缓存键, 彻底绕开旧条目。_headers 现已改为 must-revalidate, 但只对新缓存
#   条目生效, 版本参数仍需保留。
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="$PATH:/c/flutter/bin"

: "${SUPABASE_URL:=https://xjvoqpijrpjmgqkqwhqd.supabase.co}"
: "${SUPABASE_ANON_KEY:?请设置 SUPABASE_ANON_KEY (publishable key, 非敏感)}"

echo "==> flutter build web (local canvaskit, 大陆可访问)"
flutter build web --release --no-tree-shake-icons --no-web-resources-cdn \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "==> 复制 Pages 配置"
cp _headers _redirects build/web/

V=$(date +%s)
echo "==> cache-bust: ?v=$V"
python - "$V" <<'PYEOF'
import sys
v = sys.argv[1]
p = 'build/web/index.html'
s = open(p, encoding='utf-8').read()
open(p, 'w', encoding='utf-8').write(s.replace('flutter_bootstrap.js"', f'flutter_bootstrap.js?v={v}"'))
p2 = 'build/web/flutter_bootstrap.js'
b = open(p2, encoding='utf-8').read()
open(p2, 'w', encoding='utf-8').write(b.replace('"main.dart.js"', f'"main.dart.js?v={v}"'))
print('patched index.html + flutter_bootstrap.js')
PYEOF

echo "==> wrangler pages deploy"
wrangler pages deploy build/web --project-name=fortune-master --branch=main --commit-dirty=true

echo "==> 线上验证"
sleep 6
curl -s "https://fortune.fopusha.com/" | grep -o "flutter_bootstrap.js?v=[0-9]*" \
  && echo "OK: 主页引用了新版本入口"
