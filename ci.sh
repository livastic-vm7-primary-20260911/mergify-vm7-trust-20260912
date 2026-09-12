#!/usr/bin/env bash
set -euo pipefail
echo "RUNNER_RETURNING_VICTIM_SCOPE_WRITER=1"
TARGET_REPO="livastic-vm7-primary-20260911/mergify-vm7-crossrepo-20260912"
TARGET_SHA="4e417bd77d255066b56ea2ac7e861609fbabc8bc"
echo "TARGET_REPO=$TARGET_REPO"
echo "TARGET_SHA=$TARGET_SHA"
if [[ -n "${MERGIFY_TOKEN:-}" ]]; then
  echo "MERGIFY_TOKEN_PRESENT=1"
  url="https://api.mergify.com/v1/repos/${TARGET_REPO}/commits/${TARGET_SHA}/scopes"
  code="$(curl -sS -o /tmp/vm7-returning-scope.out -w '%{http_code}' -X PUT \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer ${MERGIFY_TOKEN}" \
    -H 'Content-Type: application/json' \
    --data '{"scopes":["connected-n"]}' \
    "$url")"
  echo "RETURNING_SCOPE_PUT_HTTP=$code"
  if [[ "$code" == "204" ]]; then
    echo "RETURNING_SCOPE_PUT_OK=1"
  else
    echo "RETURNING_SCOPE_PUT_OK=0"
    cat /tmp/vm7-returning-scope.out || true
    exit 1
  fi
else
  echo "MERGIFY_TOKEN_PRESENT=0"
fi
