# The script is used to create a SSH key pair that is used to connect to the VM.
#!/usr/bin/env bash

# Check if the key pair already exists
if [ -f ~/.ssh/id_rsa ]; then
    echo "SSH key pair already exists. Please delete the existing key pair or use a different name."
    exit 1
fi

# Create the SSH key pair
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -q -C "camille.he@outlook.com"

# View public key (for sharing with Azure/Terraform)
echo "Public key:"
cat ~/.ssh/id_rsa.pub

# View private key fingerprint
echo "Private key fingerprint:"
ssh-keygen -lf ~/.ssh/id_rsa

echo "SSH key pair created successfully. The public key is ~/.ssh/id_rsa.pub."

# Secure private key (read/write only for owner)
echo "Securing private key (read/write only for owner)..."
chmod 600 ~/.ssh/id_rsa

# Secure public key (readable by owner only)
echo "Securing public key (readable by owner only)..."
chmod 644 ~/.ssh/id_rsa.pub

# Secure .ssh directory (readable/writable by owner only)
echo "Securing .ssh directory (readable/writable by owner only)..."
chmod 700 ~/.ssh
