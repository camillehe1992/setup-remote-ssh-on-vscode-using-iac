#!/bin/bash
# AWS Linux 2023 bootstrap for Ansible-based remote development setup

set -euo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "$(date): Starting minimal bootstrap for AWS Linux 2023"

echo "[*] Updating system packages..."
dnf update -y

echo "[*] Installing bootstrap dependencies for Ansible..."
dnf install -y \
    python3 \
    git \
    curl \
    tar \
    unzip \
    rsync

echo "[*] Preparing remote development user directories..."
mkdir -p /home/ec2-user/.ssh
mkdir -p /home/ec2-user/workspace
touch /home/ec2-user/.ssh/authorized_keys
chmod 700 /home/ec2-user/.ssh
chmod 600 /home/ec2-user/.ssh/authorized_keys
chown -R ec2-user:ec2-user /home/ec2-user/.ssh /home/ec2-user/workspace

cat > /etc/motd <<'EOF'
This instance is bootstrapped for Ansible-based configuration.

Next steps:
  1. Update aws/linux/ansible/inventory/dev.ini with this instance IP
  2. Run: just ansible-ping
  3. Run: just ansible-bootstrap
EOF

echo "$(date): Minimal bootstrap completed"
echo "[*] SSH is available with the EC2 key pair."
echo "[*] Python 3 is installed for Ansible remote execution."
echo "[*] Workspace prepared at /home/ec2-user/workspace."
