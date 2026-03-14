# Remote SSH on VSCode - Terraform Infrastructure for AWS

This Terraform configuration sets up AWS infrastructure for remote SSH development with VSCode.

This Terraform configuration provides:

1. **Complete variable configuration** for all resources
2. **Spot instance support** with fallback to on-demand
3. **Automatic IP detection** for SSH security group
4. **IAM roles** with the specified policies
5. **EBS data volume** with gp3 type
6. **Daily backup** with 7-day retention (configurable)
7. **User data script** to mount the data volume automatically
8. **Proper outputs** including SSH connection command

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

## Infra Provisioning Steps

1. Update the variables in `variables.tf` or use environment variables.
2. Initialize Terraform using `just init aws`
3. Review the execution plan using `just plan aws`
4. Apply the configuration using `just apply aws`
5. Connect to your instance using the SSH command from `just ssh-cmd`, and copy the command to your clipboard. Run the command in your terminal to connect to the instance. You will be prompted to accept the host key. Type `yes` and press Enter. A view as below will be displayed with the instance information. You can now use VSCode to connect to the instance.

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

## Setup SSH Config for Remote Connection

1. First of all, you should have installed the "Remote - SSH" extension in VSCode.
2. Make sure you have the pem-key file in `~/.ssh/` directory. The default file name is `aws-remote-ssh-on-vscode.pem`.
3. Run `just add-ssh-config` to add the SSH host entry to ~/.ssh/config.
4. Use "Remote-SSH: Connect to Host" in VSCode and select "aws-dev-instance". The green bar on the bottom left corner of VSCode will display "SSH: aws-dev-instance" which indicates the connection is successful.
    <img src="../docs/aws-remote-ssh-setup.png" width="600" alt="Connect to Instance">

Now, you can take the journey of remote development with VSCode.

> **Note**: For security concerns, Currently the SSH access is only allowed from your current IP. You can update the security group rule for SSH access using `just update-ssh-ip` after the instance is provisioned.

## Clean Up

- Remove the SSH host entry from ~/.ssh/config
- Destroy the Terraform resources when done:

    ```bash
    just plan-destroy aws
    just apply aws
    ```

> Note: This will delete all resources including EBS snapshots.
