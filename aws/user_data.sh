#!/bin/bash
# AWS Linux 2023 Remote Development Environment Bootstrap
# Simplified version for VS Code Remote Development

# ============================================
# Package Versions (Configurable at the top)
# ============================================
TERRAFORM_VERSION="1.14.0"
TERRAGRUNT_VERSION="v0.82.0"
DOCKER_COMPOSE_VERSION="latest"  # "latest" or specific version like "v2.24.0"

# ============================================
# Script Execution
# ============================================
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "$(date): Starting AWS Linux 2023 development environment bootstrap"
echo "Installing: Terraform $TERRAFORM_VERSION"

# ============================================
# System Updates and Prerequisites
# ============================================
echo "Updating system packages..."
dnf update -y

echo "Installing essential development tools and utilities..."
dnf groupinstall -y "Development Tools"

echo "Installing common utilities..."
dnf install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    tree \
    jq \
    unzip \
    zip \
    tar \
    gzip \
    make \
    cmake \
    gcc \
    gcc-c++ \
    kernel-devel \
    openssl-devel \
    readline-devel \
    zlib-devel \
    libffi-devel \
    libyaml-devel \
    sqlite-devel \
    ncurses-devel \
    tk-devel \
    gdbm-devel \
    xz-devel \
    bzip2-devel \
    rsync \
    net-tools \
    bind-utils \
    telnet \
    nc \
    lsof \
    strace \
    sysstat \
    bash-completion \
    bash-completion-extras \
    zsh \
    fzf \
    httpie \
    yq

# ============================================
# SSH Configuration for VS Code Remote
# ============================================
echo "Configuring SSH for VS Code Remote Development..."

# Configure SSH for better performance
cat > /etc/ssh/sshd_config.d/99-vscode.conf <<EOF
# VS Code Remote Development Settings
ClientAliveInterval 60
ClientAliveCountMax 3
TCPKeepAlive yes
AllowTcpForwarding yes
X11Forwarding yes
MaxSessions 20
EOF

# Set up SSH directory for ec2-user
mkdir -p /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh
touch /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
chown -R ec2-user:ec2-user /home/ec2-user/.ssh

# Disable password authentication for security
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

# ============================================
# Install Docker
# ============================================
echo "Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install Docker Compose
if [ "$DOCKER_COMPOSE_VERSION" = "latest" ]; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
else
    curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
fi
chmod +x /usr/local/bin/docker-compose

# ============================================
# Install Terraform and Terragrunt
# ============================================
echo "Installing Terraform $TERRAFORM_VERSION and Terragrunt $TERRAGRUNT_VERSION..."

# Install Terraform
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Terragrunt
wget https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# ============================================
# Install Cloud CLIs
# ============================================
echo "Installing Cloud CLIs..."

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# ============================================
# Install Oh-My-Zsh and Plugins
# ============================================
echo "Installing Oh-My-Zsh with plugins..."

# Install Oh-My-Zsh
su - ec2-user -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Install custom plugins
su - ec2-user -c "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/home/ec2-user/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
su - ec2-user -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-/home/ec2-user/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
su - ec2-user -c "git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-/home/ec2-user/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
su - ec2-user -c "git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-/home/ec2-user/.oh-my-zsh/custom}/plugins/zsh-completions"

# Configure .zshrc
cat > /home/ec2-user/.zshrc <<'EOF'
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  docker
  docker-compose
  kubectl
  terraform
  aws
  npm
  node
  python
  pip
  pyenv
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-completions
  history
  colored-man-pages
  command-not-found
  extract
  rsync
  ssh
  tmux
  vscode
)

source $ZSH/oh-my-zsh.sh

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias g='git'
alias gs='git status'
alias d='docker'
alias dc='docker-compose'
alias tf='terraform'
alias tg='terragrunt'
alias k='kubectl'
alias py='python3'
alias ipy='ipython'
alias serve='python3 -m http.server'
alias ports='netstat -tulanp'

# Custom prompt
autoload -Uz promptinit
promptinit
EOF

# Set zsh as default shell
chsh -s $(which zsh) ec2-user

# ============================================
# Create Workspace Directory
# ============================================
mkdir -p /home/ec2-user/workspace
chown -R ec2-user:ec2-user /home/ec2-user/workspace

# ============================================
# Set proper ownership
# ============================================
chown -R ec2-user:ec2-user /home/ec2-user

# ============================================
# Firewall Configuration
# ============================================
echo "Configuring firewall..."

if systemctl is-enabled firewalld &>/dev/null; then
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --permanent --add-port=3000-3010/tcp
    firewall-cmd --permanent --add-port=5000-5010/tcp
    firewall-cmd --permanent --add-port=8000-8010/tcp
    firewall-cmd --reload
fi

# ============================================
# Version Verification
# ============================================
echo "Verifying installations..."

# Create verification script
cat > /home/ec2-user/verify-installations.sh <<'EOF'
#!/bin/bash
echo "=========================================="
echo "Installed Versions"
echo "=========================================="
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Terraform: $(terraform version | head -n1)"
echo "Terragrunt: $(terragrunt --version)"
echo "AWS CLI: $(aws --version)"
echo "=========================================="
EOF

chmod +x /home/ec2-user/verify-installations.sh
chown ec2-user:ec2-user /home/ec2-user/verify-installations.sh

# ============================================
# Final Message
# ============================================
echo "$(date): AWS Linux 2023 development environment bootstrap completed"
echo "=========================================="
echo "✅ Development environment ready!"
echo "=========================================="
echo "📁 Workspace: /home/ec2-user/workspace"
echo "🔑 SSH: ssh ec2-user@$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo ""
echo "📦 Package Versions Installed:"
echo "  • Terraform: $TERRAFORM_VERSION"
echo "  • Terragrunt: $TERRAGRUNT_VERSION"
echo "  • Docker Compose: $DOCKER_COMPOSE_VERSION"
echo ""
echo "🚀 Quick Test: Run '~/verify-installations.sh' to see all versions"
echo "=========================================="
