# justfile - Task runner for Terraform workflows
# Usage: just plan [cloud-provider]
# Example: just plan aws

# Cloud Provider
cloud-provider := "aws"

# Project root directory (where the justfile is located)
PROJECT_ROOT := `pwd`

# Shell to use
set shell := ["bash", "-uc"]
set dotenv-load := true


versions:
    #!/usr/bin/env bash
    echo "Show version information for installed tools..."
    echo "Terraform version: $(terraform version)"
    echo "markdownlint-cli version: $(markdownlint --version)"
    echo "terraform-docs version: $(terraform-docs --version)"
    echo "pre-commit version: $(pre-commit -V)"
    echo "checkov version: $(checkov --version)"
    echo "trivy version: $(trivy --version)"
    # Install CLI for cloud providers as needed
    echo "AWS version $(aws --version | head -n 1)"
    echo "Azure version $(az --version | head -n 1)"
    echo "AliCloud version $(aliyun --version | head -n 1)"

# Get cloud-provider profile
# aws-profile:
#     #!/usr/bin/env bash
#     # Check if running in GitHub Actions
#     if [ -n "$GITHUB_ACTIONS" ]; then
#         # In GitHub Actions with OIDC, we don't use named profiles
#         # The credentials are already set by configure-aws-credentials
#         echo ""
#     elif [ -f .env ]; then
#         source .env && echo "${AWS_PROFILE:-app-deployer}"
#     else
#         echo "app-deployer"
#     fi

# azure-profile:
#     #!/usr/bin/env bash
#     # Check if running in GitHub Actions
#     if [ -n "$GITHUB_ACTIONS" ]; then
#         # In GitHub Actions with OIDC, we don't use named profiles
#         # The credentials are already set by configure-azure-credentials
#         echo ""
#     elif [ -f .env ]; then
#         source .env && echo "${AZURE_PROFILE:-azure-deployer}"
#     else
#         echo "azure-deployer"
#     fi

# aliyun-profile:
#     #!/usr/bin/env bash
#     # Check if running in GitHub Actions
#     if [ -n "$GITHUB_ACTIONS" ]; then
#         # In GitHub Actions with OIDC, we don't use named profiles
#         # The credentials are already set by configure-aliyun-credentials
#         echo ""
#     elif [ -f .env ]; then
#         source .env && echo "${ALICLOUD_PROFILE:-aliyun-deployer}"
#     else
#         echo "aliyun-deployer"
#     fi

# ------------------------------------------------------------------------------
# Path helpers (as recipes)
# ------------------------------------------------------------------------------

# Cloud Provider directory
tf-cp-dir cloud-provider:
    #!/usr/bin/env bash
    echo "{{PROJECT_ROOT}}/{{cloud-provider}}/"

# ------------------------------------------------------------------------------
# Core commands
# ------------------------------------------------------------------------------
clean:
    #!/usr/bin/env bash
    echo "[*] Cleaning up temporary files"
    find {{PROJECT_ROOT}} -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
    find {{PROJECT_ROOT}} -type f -name "*.tfstate*" -delete
    echo "[*] Cleaning up completed"

lint-md:
    #!/usr/bin/env bash
    echo "Linting markdown files..."
    markdownlint "**/*.md"

# Generate Terraform Docs for all cloud providers
gen-docs:
    #!/usr/bin/env bash
    echo "[*] Generating Terraform Docs for all cloud providers..."
    for cloud_provider in */; do
        # run just only in a folder contains justfile
        if [ -f ${cloud_provider}/justfile ]; then
            just ${cloud_provider}/gen-docs
        fi
    done
