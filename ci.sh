#!/usr/bin/env bash
set -euo pipefail

echo 'MERGIFY_KEY_PROBE=1'
if [[ -n "${MERGIFY_TOKEN:-}" ]]; then
  echo 'MERGIFY_TOKEN_PRESENT=1'
  printf '%s' "$MERGIFY_TOKEN" | sha256sum | awk '{print "MERGIFY_TOKEN_SHA256="$1}'
  app="$(curl -fsS -H "Authorization: Bearer ${MERGIFY_TOKEN}" https://api.mergify.com/v1/application)"
  APP="$app" python3 - <<'PY'
import os,json
d=json.loads(os.environ['APP'])
print('MERGIFY_APPLICATION_SCOPE='+str(d.get('scope')))
a=d.get('account_scope') or {}
print('MERGIFY_APPLICATION_ACCOUNT='+str(a.get('login')))
PY
else
  echo 'MERGIFY_TOKEN_PRESENT=0'
fi
if [[ -n "${VM7_CANARY:-}" ]]; then
  echo 'CANARY_PRESENT=1'
else
  echo 'CANARY_PRESENT=0'
fi
