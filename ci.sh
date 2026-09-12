#!/usr/bin/env bash
set -euo pipefail

echo 'RUNNER_ACCOUNT_WIDE_PROBE=1'
TARGET_B_REPO='livastic-vm7-primary-20260911/mergify-vm7-crossrepo-20260912'
TARGET_B_SHA='4507877500fddc3dd5e76cbd595177e62097be9b'
TARGET_C_REPO='livastic-vm7-primary-20260911/mergify-vm7-prbody-20260912'
TARGET_C_SHA='24ce677cb56c585cf9390c03358bbc7a9f98cc74'
if [[ -n "${MERGIFY_TOKEN:-}" ]]; then
  echo 'MERGIFY_TOKEN_PRESENT=1'
  code_b="$(curl -sS -o /tmp/mergify-crossrepo-b.json -w '%{http_code}' -X PUT -H 'Accept: application/json' -H "Authorization: Bearer ${MERGIFY_TOKEN}" -H 'Content-Type: application/json' -d '{"scopes":["runner-account-wide-b"]}' "https://api.mergify.com/v1/repos/${TARGET_B_REPO}/commits/${TARGET_B_SHA}/scopes")"
  echo "ACCOUNT_WIDE_B_PUT_HTTP=${code_b}"
  code_c="$(curl -sS -o /tmp/mergify-crossrepo-c.json -w '%{http_code}' -X PUT -H 'Accept: application/json' -H "Authorization: Bearer ${MERGIFY_TOKEN}" -H 'Content-Type: application/json' -d '{"scopes":["runner-account-wide-c"]}' "https://api.mergify.com/v1/repos/${TARGET_C_REPO}/commits/${TARGET_C_SHA}/scopes")"
  echo "ACCOUNT_WIDE_C_PUT_HTTP=${code_c}"
  if [[ "$code_b" != '204' || "$code_c" != '204' ]]; then
    echo 'ACCOUNT_WIDE_PUT_FAILED=1'
    exit 1
  fi
  echo 'ACCOUNT_WIDE_TWO_REPO_PUT_OK=1'
else
  echo 'MERGIFY_TOKEN_PRESENT=0'
  echo 'ACCOUNT_WIDE_TWO_REPO_PUT_SKIPPED=1'
fi
