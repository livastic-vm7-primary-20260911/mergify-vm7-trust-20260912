#!/usr/bin/env bash
set -euo pipefail

echo 'RUNNER_CONNECTED_IMPACT_PROBE=1'
TARGET_REPO='livastic-vm7-primary-20260911/mergify-vm7-crossrepo-20260912'
M_SHA='626fb81c60d86c10aa43341f33c043d55c5ebb0f'
N_SHA='563e5830ad60752a70e319d5c4ad2ccf8e3e6437'
if [[ -n "${MERGIFY_TOKEN:-}" ]]; then
  echo 'MERGIFY_TOKEN_PRESENT=1'
  code_m="$(curl -sS -o /tmp/mergify-connected-m.json -w '%{http_code}' -X PUT -H 'Accept: application/json' -H "Authorization: Bearer $MERGIFY_TOKEN" -H 'Content-Type: application/json' -d '{"scopes":["connected-m"]}' "https://api.mergify.com/v1/repos/${TARGET_REPO}/commits/${M_SHA}/scopes")"
  code_n="$(curl -sS -o /tmp/mergify-connected-n.json -w '%{http_code}' -X PUT -H 'Accept: application/json' -H "Authorization: Bearer $MERGIFY_TOKEN" -H 'Content-Type: application/json' -d '{"scopes":["connected-n"]}' "https://api.mergify.com/v1/repos/${TARGET_REPO}/commits/${N_SHA}/scopes")"
  echo "CONNECTED_M_SCOPE_PUT_HTTP=$code_m"
  echo "CONNECTED_N_SCOPE_PUT_HTTP=$code_n"
  if [[ "$code_m" == '204' && "$code_n" == '204' ]]; then
    echo 'CONNECTED_TWO_SCOPE_PUT_OK=1'
  else
    echo 'CONNECTED_SCOPE_PUT_FAILED=1'
    exit 1
  fi
else
  echo 'MERGIFY_TOKEN_PRESENT=0'
  echo 'CONNECTED_SCOPE_PUT_SKIPPED=1'
fi
