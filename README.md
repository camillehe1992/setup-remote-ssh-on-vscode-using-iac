# Set Up VS Code Remote SSH on AWS with IaC

This repository provisions an AWS remote development instance with Terraform
and configures it with Ansible. AWS is the active, supported workflow during
the current refactor; the Azure and Alibaba Cloud directories are not exposed
through the root command interface yet.

## Prerequisites

For local development, you need to install the following tools:

- Terraform: [Official Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- just: [Official Installation Guide](https://github.com/casey/just#installation)
- markdownlint-cli: [Official Installation Guide](https://github.com/DavidAnson/markdownlint-cli#installation)
- pre-commit: [Official Installation Guide](https://pre-commit.com/#install)
- Checkov: [Official Installation Guide](https://www.checkov.io/1.Getting%20Started/Installation.html)
- Trivy: [Official Installation Guide](https://aquasecurity.github.io/trivy/v0.32/getting-started/installation/)

For Cloud Provider

- AWS: [Official Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Azure: [Official Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Alibaba Cloud: [Official Installation Guide](https://www.alibabacloud.com/help/en/cli/)

For MacOS users, you can use Homebrew to install Terraform and AWS CLI and other necessary packages using `brew` as below:

  ```bash
  brew update

  brew install terraform just markdownlint-cli pre-commit checkov trivy ansible

  brew install awscli azure-cli aliyun-cli
  ```

Then run `just versions` to verify the installation.

After installation, configure AWS credentials for Terraform by following the
[AWS CLI guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html).

From the repository root, verify the configured AWS identity:

```bash
just aws pre-check
```

## Get Started

Clone repository to local machine.

```bash
git clone https://github.com/heyachao/setup-remote-ssh-on-vscode-using-iac.git
cd setup-remote-ssh-on-vscode-using-iac
```

## AWS Workflow

Run AWS recipes from the repository root with `just aws <recipe>`. Any
additional argument is forwarded to the AWS workflow; for example,
`just aws plan linux` explicitly selects the Linux module.

| Command | Description |
| --- | --- |
| `just aws pre-check` | Verify AWS credentials and workflow settings. |
| `just aws create-ssh-key` | Create the default EC2 SSH key pair. |
| `just aws init` | Initialize the Terraform S3 backend. |
| `just aws plan` | Create a Terraform provisioning plan. |
| `just aws apply` | Apply the previously created plan. |
| `just aws plan-apply` | Create and apply a provisioning plan. |
| `just aws destroy` | Create a Terraform destruction plan. |
| `just aws destroy-apply` | Create and apply a destruction plan. |
| `just aws output` | Print Terraform outputs. |
| `just aws ssh-connect` | Print the SSH connection command. |
| `just aws add-ssh-config` | Add the instance to the local SSH config. |
| `just aws update-ssh-ip` | Update the allowed SSH source IP. |
| `just aws ansible-ping` | Test Ansible connectivity. |
| `just aws ansible-syntax-check` | Validate the Ansible bootstrap playbook syntax. |
| `just aws ansible-bootstrap` | Configure the remote development instance. |
| `just aws ansible-bootstrap-check` | Preview Ansible changes without applying them. |

The AWS recipes remain directly available from the provider directory:

```bash
cd aws
just plan
just ansible-bootstrap
```

Use `just --list` at the repository root or `cd aws && just --list` to inspect
the currently available recipes.

## References

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [AWS Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Credentials](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
- [Alibaba Cloud CLI](https://www.alibabacloud.com/help/en/cli/)
- [Alibaba Cloud Credentials](https://www.alibabacloud.com/help/en/cli/2020-04-01/configure-credentials.html)
