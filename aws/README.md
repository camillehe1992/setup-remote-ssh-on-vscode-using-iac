# Remote SSH on VSCode - Terraform Infrastructure for AWS

This Terraform configuration creates a fully-configured development environment in AWS with VS Code Server, persistent data storage, and automated backups.

## Features

- 🚀 **VS Code Server** pre-installed and configured
- 💰 **Spot instance support** with fallback to on-demand
- 🔒 **Automatic IP detection** for SSH security group
- 🔄 **IAM roles** with the specified policies
- 💾 **EBS data volume** with gp3 type
- 💽 **Daily backup** with 7-day retention (configurable)
- 📦 **User data script** to mount the data volume automatically
- 🎯 **Proper outputs** including SSH connection command

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.14.0
- AWS CLI configured with appropriate credentials
- Existing EC2 key pair in your AWS account or create a new one using `just create-ssh-key`

## Resources Created

- EC2 Instance (Amazon Linux 2023) with t3.micro instance type (Spot Instance enabled for cost optimization)
- EBS Data Volume (50GB gp3)
- Security Group (SSH access from your IP for security reasons)
- IAM Role with EC2 and SSM permissions
- Optional: Daily EBS snapshots with 7-day retention (Spot instance may be terminated, so snapshots are stored for cost optimization)

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

    ```text
    ,     #_
    ~\_  ####_        Amazon Linux 2023
    ~~  \_#####\
    ~~     \###|
    ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
    ~~       V~' '->
        ~~~         /
        ~~._.   _/
            _/ _/
        _/m/'
    ```

Now, you can close the connection from terminal, and use VSCode to connect to the instance.

## Setup SSH Config for Remote Connection

1. First of all, you should have installed the "Remote - SSH" extension in VSCode.
2. Make sure you have the pem-key file in `~/.ssh/` directory. The default file name is `aws-remote-ssh-on-vscode.pem`.
3. Run `just add-ssh-config` to add the SSH host entry to ~/.ssh/config.
4. Open VSCode, and click on the "Open a remote window" icon in the bottom left corner. You will see a dropdown menu. Choose "Connect to Host" from the menu. Select "aws-dev-instance". A new VSCode window will be opened with the instance as the remote host after the connection is successful.
5. The green bar on the bottom left corner of VSCode will display "SSH: aws-dev-instance" which indicates the connection is successful.
    <img src="../docs/aws-remote-ssh-setup.png" width="600" alt="Connect to Instance">

Now, you can take the journey of remote development with VSCode.

> **Note**: For security concerns, Currently the SSH access is only allowed from your current IP. You can update the security group rule for SSH access using `just update-ssh-ip` when you need to access the instance from a different IP.

## Clean Up

- Remove the SSH host entry from ~/.ssh/config if you no longer need it.
- Destroy the Terraform resources:

    ```bash
    just plan-destroy
    just apply
    ```

> Note: This will delete all resources including EBS snapshots.
