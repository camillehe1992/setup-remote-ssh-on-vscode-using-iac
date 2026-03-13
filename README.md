# Setup Remote SSH on VScode using AWS with IaC

## Prerequisites

For local development, you need to install the following tools:

- Terraform: [Official Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- just: [Official Installation Guide](https://github.com/casey/just#installation)
- markdownlint-cli: [Official Installation Guide](https://github.com/DavidAnson/markdownlint-cli#installation)
- terraform-docs: [Official Installation Guide](https://terraform-docs.io/user-guide/installation/)
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

  brew install terraform just markdownlint-cli terraform-docs pre-commit checkov trivy
  
  brew install awscli azure-cli aliyun-cli
  ```

Then run `just version` to verify the installation.

After installation, you need to set up Cloud Provider credentials for Terraform to use. Please follow the [Official Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html).

Then run `just pre-check` to validate the Cloud Provider credentials is set up correctly.

- aws: `just pre-check aws`
- azure: `just pre-check azure`
- alibaba cloud: `just pre-check aliyun`

## Get Started

Clone repository to local machine.

```bash
git clone https://github.com/heyachao/setup-remote-ssh-on-vscode-using-iac.git
cd setup-remote-ssh-on-vscode-using-iac
```

## Provision the Infrastructure to Target Cloud Provider

Run just recipes to plan-apply infrastructure to target Cloud Provider, for example:

| Command                           | Description                                                     |
| --------------------------------- | --------------------------------------------------------------- |
| `just init <cloud-provider>`      | Initialize Terraform infrastructure for target Cloud Provider.  |
| `just plan <cloud-provider>`      | Plan the Terraform infrastructure for target Cloud Provider.    |
| `just apply <cloud-provider>`     | Apply the Terraform infrastructure for target Cloud Provider.   |
| `just destroy <cloud-provider>`   | Destroy the Terraform infrastructure for target Cloud Provider. |
| `just output <cloud-provider>`    | Output the Terraform infrastructure for target Cloud Provider.  |
| `just pre-check <cloud-provider>` | Pre-check the Cloud Provider credentials for Terraform to use.  |
| `just validate <cloud-provider>`  | Validate the Terraform configuration for target Cloud Provider. |
| `just lint <cloud-provider>`      | Lint the Terraform configuration for target Cloud Provider.     |
| `just fmt <cloud-provider>`       | Format the Terraform configuration for target Cloud Provider.   |

## References

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [AWS Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Credentials](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
- [Alibaba Cloud CLI](https://www.alibabacloud.com/help/en/cli/)
- [Alibaba Cloud Credentials](https://www.alibabacloud.com/help/en/cli/2020-04-01/configure-credentials.html)
