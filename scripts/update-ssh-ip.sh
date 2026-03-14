#!/bin/bash
# save as ~/bin/update-ssh-ip.sh

# Configuration - replace with your values
AWS_PROFILE=$1
SECURITY_GROUP_ID=$2
RULE_DESCRIPTION=${3:-"Allow SSH access"}
SSH_PORT=(${4:-22})

# Get current public IP
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
CURRENT_CIDR="$CURRENT_IP/32"

echo "Current IP: $CURRENT_IP"

# Find existing rule with this description
EXISTING_RULE=$(aws ec2 describe-security-groups \
    --group-ids $SECURITY_GROUP_ID \
    --profile $AWS_PROFILE \
    --query "SecurityGroups[0].IpPermissions[?FromPort==\`$SSH_PORT\`].IpRanges[0].CidrIp" \
    --output text)

if [ "$EXISTING_RULE" != "$CURRENT_CIDR" ]; then
    echo "IP changed from $EXISTING_RULE to $CURRENT_CIDR - updating..."

    # Remove old rule if exists
    if [ ! -z "$EXISTING_RULE" ]; then
        aws ec2 revoke-security-group-ingress \
            --group-id $SECURITY_GROUP_ID \
            --protocol tcp \
            --port $SSH_PORT \
            --cidr $EXISTING_RULE \
            --profile $AWS_PROFILE
    fi

    # Add new rule
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port $SSH_PORT \
        --cidr $CURRENT_CIDR \
        --profile $AWS_PROFILE

    echo "Security group updated successfully"
else
    echo "IP unchanged - no action needed"
fi
