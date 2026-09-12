#!/usr/bin/env bash
set -euo pipefail

echo 'RUNNER_CROSSREPO_PROBE=1'
TARGET_REPO='livastic-vm7-primary-20260911/mergify-vm7-crossrepo-20260912'
TARGET_SHA='4507877500fddc3dd5e76cbd595177e62097be9b'
if [[ -n "${MERGIFY_TOKEN:-}" ]]; then
  echo 'MERGIFY_TOKEN_PRESENT=1'
  code="$(curl -sS -o /tmp/mergify-crossrepo-write.json -w '%{http_code}' -X PUT \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer ${MERGIFY_TOKEN}" \
    -H 'Content-Type: application/json' \
    -d '{"scopes":["runner-crossrepo-proof"]}' \
    "https://api.mergify.com/v1/repos/${TARGET_REPO}/commits/${TARGET_SHA}/scopes")"
  echo "CROSSREPO_SCOPE_PUT_HTTP=${code}"
  if [[ "$code" != '204' ]]; then
    echo 'CROSSREPO_SCOPE_PUT_FAILED=1'
    exit 1
  fi
  echo 'CROSSREPO_SCOPE_PUT_OK=1'
else
  echo 'MERGIFY_TOKEN_PRESENT=0'
  echo 'CROSSREPO_SCOPE_PUT_SKIPPED=1'
fi
