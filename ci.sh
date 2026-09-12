#!/usr/bin/env bash
set -euo pipefail
echo "RUNNER_CONNECTED_CORRECTED_IMPACT_PROBE=1"
echo "TARGET_REPO=livastic-vm7-primary-20260911/mergify-vm7-crossrepo-20260912"
M_SHA="626fb81c60d86c10aa43341f33c043d55c5ebb0f"
N_SHA="563e5830ad60752a70e319d5c4ad2ccf8e3e6437"
echo "M_SHA=$M_SHA"
echo "N_SHA=$N_SHA"
if [[ -n "${MERGIFY_TOKEN:-}" ]]; then
  echo "MERGIFY_TOKEN_PRESENT=1"
  TARGET_REPO="livastic-vm7-primary-20260911/mergify-vm7-crossrepo-20260912"
  M_URL="https://api.mergify.com/v1/repos/${TARGET_REPO}/commits/${M_SHA}/scopes"
  N_URL="https://api.mergify.com/v1/repos/${TARGET_REPO}/commits/${N_SHA}/scopes"
  m_code="$(curl -sS -o /tmp/vm7-connected-m.out -w '%{http_code}' -X PUT \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer ${MERGIFY_TOKEN}" \
    -H 'Content-Type: application/json' \
    --data '{"scopes":["connected-m"]}' \
    "$M_URL")"
  n_code="$(curl -sS -o /tmp/vm7-connected-n.out -w '%{http_code}' -X PUT \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer ${MERGIFY_TOKEN}" \
    -H 'Content-Type: application/json' \
    --data '{"scopes":["connected-n"]}' \
    "$N_URL")"
  echo "CONNECTED_M_SCOPE_PUT_HTTP=$m_code"
  echo "CONNECTED_N_SCOPE_PUT_HTTP=$n_code"
  if [[ "$m_code" == "204" && "$n_code" == "204" ]]; then
    echo "CONNECTED_TWO_SCOPE_PUT_OK=1"
  else
    echo "CONNECTED_TWO_SCOPE_PUT_OK=0"
    echo '--- M response ---'
    cat /tmp/vm7-connected-m.out || true
    echo '--- N response ---'
    cat /tmp/vm7-connected-n.out || true
    exit 1
  fi
else
  echo "MERGIFY_TOKEN_PRESENT=0"
fi
