#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUTPUT_FILE=$(mktemp)
trap 'rm -f "${OUTPUT_FILE}"' EXIT

pass() {
    printf 'PASS: %s\n' "$1"
}

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

cd "${PROJECT_ROOT}"

just --list >"${OUTPUT_FILE}"
if grep -Eq '^    aws \*args' "${OUTPUT_FILE}"; then
    pass "root justfile lists the AWS dispatcher"
else
    fail "root justfile does not list an AWS dispatcher"
fi

just aws _get-cloud-provider >"${OUTPUT_FILE}"
if grep -Fxq 'aws' "${OUTPUT_FILE}"; then
    pass "AWS dispatcher forwards recipes"
else
    fail "AWS dispatcher does not forward recipes"
fi

if just aws >"${OUTPUT_FILE}" 2>&1; then
    fail "AWS dispatcher accepts an empty recipe"
fi

if grep -Fq 'Usage: just aws <recipe> [arguments]' "${OUTPUT_FILE}"; then
    pass "AWS dispatcher explains missing recipe usage"
else
    fail "AWS dispatcher does not explain missing recipe usage"
fi

if grep -Fq 'set positional-arguments' justfile &&
    ! grep -Fq 'set -- {{args}}' justfile; then
    pass "AWS dispatcher preserves positional argument boundaries"
else
    fail "AWS dispatcher interpolates arguments through the shell"
fi

IAM_VARIABLES_FILE="aws/linux/terraform/variables.tf"
EC2_FILE="aws/linux/terraform/ec2_instance.tf"

if grep -Fq 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore' "${IAM_VARIABLES_FILE}"; then
    pass "EC2 role defaults to the SSM managed-instance policy"
else
    fail "EC2 role is missing the SSM managed-instance policy"
fi

for broad_policy in AmazonEC2FullAccess AmazonSSMFullAccess EC2InstanceConnect; do
    if grep -Fq "${broad_policy}" "${IAM_VARIABLES_FILE}"; then
        fail "EC2 role still defaults to ${broad_policy}"
    fi
done
pass "EC2 role excludes broad default policies"

if grep -Fq 'dynamic "instance_market_options"' "${EC2_FILE}" &&
    grep -Fq 'for_each = var.use_spot_instance ? [1] : []' "${EC2_FILE}" &&
    grep -Fq 'market_type = "spot"' "${EC2_FILE}"; then
    pass "EC2 market options are conditional on Spot mode"
else
    fail "EC2 market options are not conditional on Spot mode"
fi

if grep -Eq 'market_type.*on-demand' "${EC2_FILE}"; then
    fail "EC2 market options still emit an on-demand market type"
else
    pass "On-Demand mode omits an invalid market type"
fi

README_FILE="README.md"

for documented_command in 'just versions' 'just aws plan' 'just aws ansible-bootstrap'; do
    if grep -Fq "${documented_command}" "${README_FILE}"; then
        pass "README documents ${documented_command}"
    else
        fail "README does not document ${documented_command}"
    fi
done

for obsolete_command in '`just version`' '`just plan <cloud-provider>`'; do
    if grep -Fq "${obsolete_command}" "${README_FILE}"; then
        fail "README still documents obsolete command ${obsolete_command}"
    fi
done
pass "README excludes obsolete root commands"
