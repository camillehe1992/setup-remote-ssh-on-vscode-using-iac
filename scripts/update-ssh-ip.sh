#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: $0 <aws-profile-or-empty> <security-group-id> [description] [port]" >&2
}

is_ipv4() {
    local ip=$1
    local octet
    local -a octets

    if [[ ! ${ip} =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 1
    fi

    IFS='.' read -r -a octets <<<"${ip}"
    for octet in "${octets[@]}"; do
        if ((10#${octet} > 255)); then
            return 1
        fi
    done
}

aws_cli() {
    if [[ -n ${AWS_PROFILE} ]]; then
        aws "$@" --profile "${AWS_PROFILE}"
    else
        aws "$@"
    fi
}

if (($# < 2 || $# > 4)); then
    usage
    exit 2
fi

AWS_PROFILE=$1
SECURITY_GROUP_ID=$2
RULE_DESCRIPTION=${3:-"SSH access"}
SSH_PORT=${4:-22}

if [[ -z ${SECURITY_GROUP_ID} ]]; then
    echo "Security group ID must not be empty." >&2
    exit 2
fi

if [[ ! ${SSH_PORT} =~ ^[0-9]+$ ]] || ((SSH_PORT < 1 || SSH_PORT > 65535)); then
    echo "SSH port must be an integer between 1 and 65535." >&2
    exit 2
fi

for required_command in aws curl jq; do
    if ! command -v "${required_command}" >/dev/null 2>&1; then
        echo "Required command not found: ${required_command}" >&2
        exit 127
    fi
done

CURRENT_IP=$(curl --fail --silent --show-error https://checkip.amazonaws.com)
CURRENT_IP=${CURRENT_IP//$'\r'/}
CURRENT_IP=${CURRENT_IP//$'\n'/}

if ! is_ipv4 "${CURRENT_IP}"; then
    echo "Public IP service returned an invalid IPv4 address: ${CURRENT_IP}" >&2
    exit 1
fi

CURRENT_CIDR="${CURRENT_IP}/32"
echo "Current IP: ${CURRENT_IP}"

RULES_JSON=$(aws_cli ec2 describe-security-group-rules \
    --filters \
    "Name=group-id,Values=${SECURITY_GROUP_ID}" \
    "Name=is-egress,Values=false" \
    "Name=ip-protocol,Values=tcp" \
    "Name=from-port,Values=${SSH_PORT}" \
    "Name=to-port,Values=${SSH_PORT}" \
    "Name=description,Values=${RULE_DESCRIPTION}" \
    --query 'SecurityGroupRules[].{SecurityGroupRuleId:SecurityGroupRuleId,CidrIpv4:CidrIpv4,Description:Description}' \
    --output json)

if ! jq -e 'type == "array"' >/dev/null <<<"${RULES_JSON}"; then
    echo "AWS returned an unexpected security group rule response." >&2
    exit 1
fi

MATCH_COUNT=$(jq 'map(select(.CidrIpv4 != null)) | length' <<<"${RULES_JSON}")
if [[ ${MATCH_COUNT} -ne 1 ]]; then
    echo "Expected exactly one IPv4 ingress rule for TCP/${SSH_PORT} with description '${RULE_DESCRIPTION}', found ${MATCH_COUNT}." >&2
    echo "Manage ambiguous SSH rules through Terraform instead of guessing a target." >&2
    exit 1
fi

RULE_ID=$(jq -r 'map(select(.CidrIpv4 != null))[0].SecurityGroupRuleId' <<<"${RULES_JSON}")
EXISTING_CIDR=$(jq -r 'map(select(.CidrIpv4 != null))[0].CidrIpv4' <<<"${RULES_JSON}")

if [[ -z ${RULE_ID} || ${RULE_ID} == "null" ]]; then
    echo "The matching SSH rule does not have a security group rule ID." >&2
    exit 1
fi

if [[ ${EXISTING_CIDR} == "${CURRENT_CIDR}" ]]; then
    echo "IP unchanged; no security group update required."
    exit 0
fi

UPDATE_JSON=$(jq -cn \
    --arg rule_id "${RULE_ID}" \
    --arg cidr "${CURRENT_CIDR}" \
    --arg description "${RULE_DESCRIPTION}" \
    --argjson port "${SSH_PORT}" \
    '[{SecurityGroupRuleId: $rule_id, SecurityGroupRule: {IpProtocol: "tcp", FromPort: $port, ToPort: $port, CidrIpv4: $cidr, Description: $description}}]')

aws_cli ec2 modify-security-group-rules \
    --group-id "${SECURITY_GROUP_ID}" \
    --security-group-rules "${UPDATE_JSON}" >/dev/null

echo "Updated ${RULE_ID} from ${EXISTING_CIDR} to ${CURRENT_CIDR}."
