# Azure Linux Remote Development Instance

This Terraform module provisions an Azure Linux development machine for VS Code Remote SSH.

## Prerequisites

- Terraform
- Azure CLI configured with a Service Principal

## Provisioning Workflow

1. Change into `azure/` and run `just pre-check`.
2. Change into `azure/linux/` and run `just init`.
3. Run `just plan`.
4. Run `just apply`.
