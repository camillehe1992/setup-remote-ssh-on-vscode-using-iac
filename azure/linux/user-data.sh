#!/bin/bash
# User data script for VSCode Remote development environment

set -e

# Variables passed from Terraform
DATA_DISK_DEVICE=${data_disk_device}
DATA_MOUNT_POINT=${data_mount_point}
ADMIN_USERNAME=${admin_username}

# Update system
apt-get update
apt-get upgrade -y

# Install common development tools
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    vim \
    htop \
    tree \
    jq \
    unzip \
    build-essential

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker $ADMIN_USERNAME

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install VS Code Server
curl -fsSL https://code-server.dev/install.sh | sh

# Configure VS Code Server as a service
systemctl enable --now code-server@$ADMIN_USERNAME

# Wait for disk to be attached
while [ ! -e $DATA_DISK_DEVICE ]; do
    echo "Waiting for data disk to be attached..."
    sleep 5
done

# Format and mount data disk
if ! blkid $DATA_DISK_DEVICE; then
    echo "Formatting data disk..."
    mkfs.ext4 $DATA_DISK_DEVICE
fi

# Create mount point
mkdir -p $DATA_MOUNT_POINT

# Mount data disk
mount $DATA_DISK_DEVICE $DATA_MOUNT_POINT

# Add to fstab for automatic mounting on reboot
echo "$DATA_DISK_DEVICE $DATA_MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab

# Set permissions
chown -R $ADMIN_USERNAME:$ADMIN_USERNAME $DATA_MOUNT_POINT

# Create directories for development
mkdir -p $DATA_MOUNT_POINT/projects
mkdir -p $DATA_MOUNT_POINT/vscode-extensions
mkdir -p $DATA_MOUNT_POINT/docker-data

# Link VS Code extensions to data disk
sudo -u $ADMIN_USERNAME ln -sf $DATA_MOUNT_POINT/vscode-extensions /home/$ADMIN_USERNAME/.local/share/code-server

# Install useful VS Code extensions
sudo -u $ADMIN_USERNAME code-server --install-extension ms-python.python
sudo -u $ADMIN_USERNAME code-server --install-extension ms-vscode.cpptools
sudo -u $ADMIN_USERNAME code-server --install-extension ms-azuretools.vscode-docker
sudo -u $ADMIN_USERNAME code-server --install-extension github.copilot
sudo -u $ADMIN_USERNAME code-server --install-extension eamodio.gitlens

# Configure VS Code settings
mkdir -p /home/$ADMIN_USERNAME/.local/share/code-server/User
cat > /home/$ADMIN_USERNAME/.local/share/code-server/User/settings.json << EOF
{
    "workbench.colorTheme": "Default Dark+",
    "editor.fontSize": 14,
    "terminal.integrated.fontSize": 13,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "extensions.autoUpdate": true,
    "docker.host": "unix:///var/run/docker.sock"
}
EOF

chown -R $ADMIN_USERNAME:$ADMIN_USERNAME /home/$ADMIN_USERNAME/.local

# Install Node.js (latest LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# Install Python and pip
apt-get install -y python3 python3-pip python3-venv

# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/$ADMIN_USERNAME/.bashrc
rm go1.21.0.linux-amd64.tar.gz

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install -y terraform

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Final permissions fix
chown -R $ADMIN_USERNAME:$ADMIN_USERNAME /home/$ADMIN_USERNAME

echo "Setup complete! VS Code Server is running on port 8080"
echo "Access it at: http://$(curl -s ifconfig.me):8080"
