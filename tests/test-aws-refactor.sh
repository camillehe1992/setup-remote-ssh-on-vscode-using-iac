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
DATA_FILE="aws/linux/terraform/data.tf"

if grep -A8 -F 'variable "instance_ami"' "${IAM_VARIABLES_FILE}" | grep -Fq 'default     = null' &&
    grep -A12 -F 'variable "instance_ami"' "${IAM_VARIABLES_FILE}" | grep -Fq 'trimspace(var.instance_ami) != ""'; then
    pass "AMI override is nullable and rejects empty strings"
else
    fail "AMI override does not use a validated nullable default"
fi

if grep -Fq 'data "aws_ssm_parameter" "al2023_ami"' "${DATA_FILE}" &&
    grep -Fq 'count = var.instance_ami == null ? 1 : 0' "${DATA_FILE}" &&
    grep -Fq '/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64' "${DATA_FILE}" &&
    grep -Fq 'instance_ami = var.instance_ami != null ? trimspace(var.instance_ami) : data.aws_ssm_parameter.al2023_ami[0].value' "${DATA_FILE}"; then
    pass "Terraform resolves the regional AL2023 AMI from SSM"
else
    fail "Terraform does not conditionally resolve the regional AL2023 AMI"
fi

if grep -Fq 'ami                    = local.instance_ami' "${EC2_FILE}"; then
    pass "EC2 consumes the resolved AMI"
else
    fail "EC2 does not consume the resolved AMI"
fi

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
