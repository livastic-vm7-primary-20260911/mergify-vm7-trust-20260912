#!/usr/bin/env bash
set -euo pipefail

echo "PROBE_EVENT=${GITHUB_EVENT_NAME:-unset}"
echo "PROBE_REPOSITORY=${GITHUB_REPOSITORY:-unset}"

if [[ -n "${VM7_CANARY:-}" ]]; then
  echo "CANARY_PRESENT=1"
  printf '%s' "$VM7_CANARY" | sha256sum | awk '{print "CANARY_SHA256="$1}'
else
  echo "CANARY_PRESENT=0"
fi

if [[ -n "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" && -n "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
  echo "OIDC_ENV_PRESENT=1"
  response="$(curl -fsS -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=vm7-mergify-probe")"
  token="$(printf '%s' "$response" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("value",""))')"
  if [[ -n "$token" ]]; then
    echo "OIDC_TOKEN_ACQUIRED=1"
    TOKEN="$token" python3 - <<'PY'
import os, base64, json
token = os.environ['TOKEN']
payload = token.split('.')[1]
payload += '=' * (-len(payload) % 4)
claims = json.loads(base64.urlsafe_b64decode(payload))
for key in ('sub','repository','event_name','ref','actor'):
    if key in claims:
        print(f"OIDC_{key.upper()}={claims[key]}")
PY
  else
    echo "OIDC_TOKEN_ACQUIRED=0"
  fi
else
  echo "OIDC_ENV_PRESENT=0"
fi
