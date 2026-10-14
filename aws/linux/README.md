# AWS Linux Remote Development Instance

This Terraform module provisions an AWS Linux development instance for VS Code Remote SSH.
Terraform creates the infrastructure, `user_data.sh` performs a minimal bootstrap, and Ansible applies the machine configuration after the instance becomes reachable over SSH.

## What Happens During Bootstrap

- Terraform creates the EC2 instance, EBS data volume, IAM profile, security group, and backup resources.
- `user_data.sh` keeps first boot intentionally small: it updates the system, installs Python 3 and a few bootstrap tools, and prepares the `ec2-user` workspace.
- Ansible lives in `aws/linux/ansible/` and is responsible for the remote development configuration layers:
  - `base`
  - `ssh_remote_dev`
  - `docker`

## Ansible Layout

```text
aws/linux/ansible/
  ansible.cfg
  inventory/dev.ini
  group_vars/all.yml
  playbooks/bootstrap.yml
  roles/
    base/
    ssh_remote_dev/
    docker/
```

## Prerequisites

- Terraform
- AWS CLI configured with the target profile
- Ansible installed on your local machine
- An EC2 key pair available in AWS and its private key present at `~/.ssh/aws-remote-ssh-on-vscode.pem`

## Provisioning Workflow

1. Change into `aws/` and run `just plan-apply` (or `just plan-apply linux`) to provision the instance.
2. Update `linux/ansible/inventory/dev.ini` with the instance public IP from `cd linux/terraform && terraform output -raw instance_public_ip`.
3. Verify Ansible connectivity with `just ansible-ping` (or `just ansible-ping linux`).
4. Run `just ansible-syntax-check`.
5. Apply the remote configuration with `just ansible-bootstrap` (or `just ansible-bootstrap linux`).
6. Connect from VS Code using the Remote SSH extension.

## Notes

- This module is currently optimized for `AWS + Amazon Linux 2023`.
- `user_data.sh` no longer installs the full development stack directly; that responsibility moves to Ansible roles for better idempotency and maintainability.
