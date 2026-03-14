#!/bin/bash
# AWS Linux 2023 Remote Development Environment Bootstrap
# Addtional Packages to Install

# ============================================
# Package Versions (Configurable at the top)
# ============================================
NODE_MAJOR_VERSION="25"
NVM_VERSION="v0.40.0"
PYTHON_VERSION="3.13.0"
GO_VERSION="1.23.0"

echo "Installing: Node.js $NODE_MAJOR_VERSION, Python $PYTHON_VERSION, Go $GO_VERSION"

# ============================================
# Install Cloud CLIs
# ============================================

# Azure CLI
rpm --import https://packages.microsoft.com/keys/microsoft.asc

sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

dnf install -y azure-cli

# Aliyun CLI
curl -LO "https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz"
tar -xzf aliyun-cli-linux-latest-amd64.tgz
mv aliyun /usr/local/bin/
rm aliyun-cli-linux-latest-amd64.tgz

echo "Azure CLI: $(az version | jq -r '.\"azure-cli\"')"
echo "Aliyun CLI: $(aliyun --version | head -n1)"

# ============================================
# Install NVM and Node.js
# ============================================
echo "Installing NVM $NVM_VERSION and Node.js $NODE_MAJOR_VERSION..."
su - ec2-user -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash"
su - ec2-user -c "export NVM_DIR=\"\$HOME/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\" && nvm install $NODE_MAJOR_VERSION && nvm alias default $NODE_MAJOR_VERSION"

# Install global npm packages
echo "Installing global npm packages..."
su - ec2-user -c "export NVM_DIR=\"\$HOME/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\" && npm install -g yarn pnpm typescript ts-node nodemon pm2 http-server serve eslint prettier"

============================================
Install Python with pyenv
============================================
echo "Installing Python $PYTHON_VERSION with pyenv..."
su - ec2-user -c "curl https://pyenv.run | bash"

# Add pyenv to bashrc
cat >> /home/ec2-user/.bashrc <<'EOF'
# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF

# Install Python
su - ec2-user -c "export PYENV_ROOT=\"\$HOME/.pyenv\" && export PATH=\"\$PYENV_ROOT/bin:\$PATH\" && eval \"\$(pyenv init -)\" && pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION"

# Install common Python packages
su - ec2-user -c "export PYENV_ROOT=\"\$HOME/.pyenv\" && export PATH=\"\$PYENV_ROOT/bin:\$PATH\" && eval \"\$(pyenv init -)\" && pip install --upgrade pip && pip install virtualenv poetry pipenv jupyter jupyterlab notebook ipython boto3"

============================================
Install Go
============================================
echo "Installing Go $GO_VERSION..."
wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
rm go$GO_VERSION.linux-amd64.tar.gz

# Add Go to bashrc
cat >> /home/ec2-user/.bashrc <<'EOF'
# Go configuration
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF

cat > /home/ec2-user/.zshrc <<'EOF'

# User configuration
export EDITOR=vim

# Path additions
export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
