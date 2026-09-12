#!/usr/bin/env bash
set -euo pipefail
echo 'STALE_BASE_AUTOQUEUE_PROBE=1'
if [[ -n "${VM7_CANARY:-}" ]]; then
  echo 'CANARY_PRESENT=1'
  printf '%s' "$VM7_CANARY" | sha256sum | awk '{print "CANARY_SHA256="$1}'
else
  echo 'CANARY_PRESENT=0'
fi
if [[ -n "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" && -n "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
  echo 'OIDC_ENV_PRESENT=1'
  response="$(curl -fsS -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=vm7-stale-autoqueue-probe")"
  token="$(printf '%s' "$response" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("value",""))')"
  [[ -n "$token" ]] && echo 'OIDC_TOKEN_ACQUIRED=1' || echo 'OIDC_TOKEN_ACQUIRED=0'
else
  echo 'OIDC_ENV_PRESENT=0'
fi
