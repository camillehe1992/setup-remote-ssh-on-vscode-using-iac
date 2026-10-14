#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d)
FAKE_BIN="${TEST_ROOT}/bin"
AWS_LOG="${TEST_ROOT}/aws.log"
CURL_LOG="${TEST_ROOT}/curl.log"
OUTPUT_FILE="${TEST_ROOT}/output.log"
trap 'rm -rf "${TEST_ROOT}"' EXIT

mkdir -p "${FAKE_BIN}"

cat >"${FAKE_BIN}/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"${FAKE_CURL_LOG}"
printf '%s\n' "${FAKE_CURRENT_IP}"
EOF

cat >"${FAKE_BIN}/aws" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"${FAKE_AWS_LOG}"

case " $* " in
    *" describe-security-group-rules "*)
        printf '%s\n' "${FAKE_RULES_JSON}"
        ;;
    *" modify-security-group-rules "*)
        printf '%s\n' '{}'
        ;;
    *)
        printf 'Unexpected AWS operation: %s\n' "$*" >&2
        exit 64
        ;;
esac
EOF

chmod +x "${FAKE_BIN}/curl" "${FAKE_BIN}/aws"

export PATH="${FAKE_BIN}:${PATH}"
export FAKE_AWS_LOG="${AWS_LOG}"
export FAKE_CURL_LOG="${CURL_LOG}"

pass() {
    printf 'PASS: %s\n' "$1"
}

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    if [ -s "${OUTPUT_FILE}" ]; then
        sed -n '1,120p' "${OUTPUT_FILE}" >&2
    fi
    exit 1
}

reset_case() {
    : >"${AWS_LOG}"
    : >"${CURL_LOG}"
    : >"${OUTPUT_FILE}"
}

run_update() {
    local profile=$1
    bash "${PROJECT_ROOT}/scripts/update-ssh-ip.sh" \
        "${profile}" "sg-1234567890" >"${OUTPUT_FILE}" 2>&1
}

export FAKE_CURRENT_IP="203.0.113.10"
export FAKE_RULES_JSON='[{"SecurityGroupRuleId":"sgr-123","CidrIpv4":"203.0.113.10/32","Description":"SSH access"}]'
reset_case
if ! run_update ""; then
    fail "unchanged CIDR should succeed"
fi
if grep -Fq 'modify-security-group-rules' "${AWS_LOG}"; then
    fail "unchanged CIDR should not be modified"
fi
if grep -Fq -- '--profile' "${AWS_LOG}"; then
    fail "empty AWS profile should be omitted"
fi
if ! grep -Fq 'https://' "${CURL_LOG}"; then
    fail "public IP lookup must use HTTPS"
fi
pass "unchanged CIDR is a no-op without an empty profile argument"

reset_case
if ! run_update "development"; then
    fail "named profile case should succeed"
fi
if ! grep -Fq -- '--profile development' "${AWS_LOG}"; then
    fail "named AWS profile should be forwarded"
fi
pass "named AWS profile is forwarded"

export FAKE_CURRENT_IP="203.0.113.11"
reset_case
if ! run_update ""; then
    fail "changed CIDR should succeed"
fi
if ! grep -Fq 'modify-security-group-rules' "${AWS_LOG}"; then
    fail "changed CIDR should use atomic rule modification"
fi
if grep -Eq 'revoke-security-group-ingress|authorize-security-group-ingress' "${AWS_LOG}"; then
    fail "changed CIDR should not revoke or authorize rules"
fi
if ! grep -Fq '203.0.113.11/32' "${AWS_LOG}"; then
    fail "atomic update should contain the new CIDR"
fi
pass "changed CIDR is modified atomically"

export FAKE_RULES_JSON='[]'
reset_case
if run_update ""; then
    fail "zero matching rules should fail"
fi
if grep -Fq 'modify-security-group-rules' "${AWS_LOG}"; then
    fail "zero matching rules should not mutate AWS"
fi
pass "zero matching rules fail safely"

export FAKE_RULES_JSON='[{"SecurityGroupRuleId":"sgr-1","CidrIpv4":"203.0.113.1/32","Description":"SSH access"},{"SecurityGroupRuleId":"sgr-2","CidrIpv4":"203.0.113.2/32","Description":"SSH access"}]'
reset_case
if run_update ""; then
    fail "multiple matching rules should fail"
fi
if grep -Fq 'modify-security-group-rules' "${AWS_LOG}"; then
    fail "multiple matching rules should not mutate AWS"
fi
pass "multiple matching rules fail safely"

export FAKE_CURRENT_IP="not-an-ip"
reset_case
if run_update ""; then
    fail "invalid public IP should fail"
fi
if [ -s "${AWS_LOG}" ]; then
    fail "invalid public IP should fail before AWS calls"
fi
pass "invalid public IP fails before AWS mutation"
