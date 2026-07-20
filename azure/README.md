# Remote SSH on VSCode - Terraform Infrastructure for Azure

This Terraform configuration creates a fully-configured development environment in Azure with VS Code Server, persistent data storage, and automated backups.

## Features

- 🚀 **VS Code Server** pre-installed and configured
- 💾 **Persistent data volume** (Premium SSD with configurable IOPS)
- 💰 **Spot instance support** with automatic fallback to on-demand
- 🔒 **Secure by default** - SSH only from your current IP
- 📦 **Development tools** pre-installed (Docker, Python, Go, Node.js, etc.)
- 💽 **Daily automated backups** with configurable retention
- 🎯 **Managed identity** with proper role assignments
- 🔄 **Auto-mounting data disk** on boot

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) configured
- SSH key pair (public key should be in `~/.ssh/azure_vscode.pub` by default)

## Resources Created

todo

## Just Recipes

A few recipes are provided for quick provisioning and cleanup. There are three ways to run recipes:

1. Run `just <recipe>` to execute the recipe from `aws/linux` directory.
2. Or run `just linux/<recipe>` from the `aws` directory of the repository.
3. Or run `just aws/linux/<recipe>` from the root directory of the repository.

> **Note**: All recipes above are equivalent. You can choose any way to run recipes.

## Infra Provisioning Steps

2. Update the variables in `variables.tf` or inject environment variables `TF_VAR_<variable_name>` from command line directly.
3. Initialize Terraform using `just init`
4. Review the execution plan using `just plan`
5. Apply the configuration using `just apply`
6. Connect to your instance using the SSH command from `just ssh-connect`, and copy the command to your clipboard. Run the command in your terminal to connect to the instance. You will be prompted to accept the host key. Type `yes` and press Enter. A view as below will be displayed when the connection is successful.

Now, you can close the connection from terminal, and use VSCode to connect to the VM.

## Setup SSH Config for Remote Connection

Option 1: Use VS Code Extension (Recommended)
Install the Azure Virtual Machines extension in VS Code

Find your VM in the Azure explorer

Right-click on your VM and select "Connect via SSH"

VS Code will automatically detect and use your local SSH key (~/.ssh/id_rsa) to connect to the VM.

## Clean Up

- Remove the SSH host entry from ~/.ssh/config if you no longer need it.
- Destroy the Terraform resources:

    ```bash
    just plan-destroy
    just apply
    ```

> Note: This will delete all resources including EBS snapshots.
