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

# ------------------------------------------------------------------------------
# Helper functions (as recipes)
# ------------------------------------------------------------------------------
versions:
    #!/usr/bin/env bash
    echo "Show version information for installed tools..."
    echo "Terraform version: $(terraform version)"
    echo "markdownlint-cli version: $(markdownlint --version)"
    echo "terraform-docs version: $(terraform-docs --version)"
    echo "pre-commit version: $(pre-commit -V)"
    echo "checkov version: $(checkov --version)"
    echo "trivy version: $(trivy --version)"

    echo "AWS version $(aws --version | head -n 1)"
    echo "Azure version $(az --version | head -n 1)"
    echo "AliCloud version $(aliyun --version | head -n 1)"

# Get cloud-provider profile
aws-profile:
    #!/usr/bin/env bash
    # Check if running in GitHub Actions
    if [ -n "$GITHUB_ACTIONS" ]; then
        # In GitHub Actions with OIDC, we don't use named profiles
        # The credentials are already set by configure-aws-credentials
        echo ""
    elif [ -f .env ]; then
        source .env && echo "${AWS_PROFILE:-app-deployer}"
    else
        echo "app-deployer"
    fi

azure-profile:
    #!/usr/bin/env bash
    # Check if running in GitHub Actions
    if [ -n "$GITHUB_ACTIONS" ]; then
        # In GitHub Actions with OIDC, we don't use named profiles
        # The credentials are already set by configure-azure-credentials
        echo ""
    elif [ -f .env ]; then
        source .env && echo "${AZURE_PROFILE:-azure-deployer}"
    else
        echo "azure-deployer"
    fi

aliyun-profile:
    #!/usr/bin/env bash
    # Check if running in GitHub Actions
    if [ -n "$GITHUB_ACTIONS" ]; then
        # In GitHub Actions with OIDC, we don't use named profiles
        # The credentials are already set by configure-aliyun-credentials
        echo ""
    elif [ -f .env ]; then
        source .env && echo "${ALICLOUD_PROFILE:-aliyun-deployer}"
    else
        echo "aliyun-deployer"
    fi

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

# Pre-check - Verify cloud-provider credentials
pre-check cloud-provider:
    #!/usr/bin/env bash
    echo "[*] Pre-Check - {{cloud-provider}} Profile..."
    set +e
    if [ "{{cloud-provider}}" == "aws" ]; then
        PROFILE=$(just aws-profile)
        AWS_PROFILE=${PROFILE} aws sts get-caller-identity | jq .
    elif [ "{{cloud-provider}}" == "azure" ]; then
        PROFILE=$(just azure-profile)
        AZURE_PROFILE=${PROFILE} az account show | jq .
    elif [ "{{cloud-provider}}" == "aliyun" ]; then
        PROFILE=$(just aliyun-profile)
        ALICLOUD_PROFILE=${PROFILE} alicloud sts:GetCallerIdentity | jq .
    else
        echo "Invalid cloud-provider: ${cloud-provider}, must be one of aws, azure or aliyun"
        exit 1
    fi

init cloud-provider:
    #!/usr/bin/env bash
    PROFILE=$(just {{cloud-provider}}-profile)
    TF_DIR=$(just tf-unit-dir {{cloud-provider}})
    echo "[*] Initializing - Terraform Unit ${TF_DIR}"
    cd ${TF_DIR} && {{cloud-provider}}_PROFILE=${PROFILE} terraform init -input=false

plan cloud-provider:
    #!/usr/bin/env bash
    just init {{cloud-provider}}
    PROFILE=$(just {{cloud-provider}}-profile)
    TF_DIR=$(just tf-unit-dir {{cloud-provider}})
    VAR_OPTIONS=$(just tf-options {{cloud-provider}})
    echo "[*] Planning - Terraform Unit ${TF_DIR}"

    cd ${TF_DIR} && {{cloud-provider}}_PROFILE=${PROFILE} terraform plan -input=false -out=tfplan

apply cloud-provider:
    #!/usr/bin/env bash
    PROFILE=$(just {{cloud-provider}}-profile)
    TF_DIR=$(just tf-unit-dir {{cloud-provider}})
    echo "[*] Applying - Terraform Unit ${TF_DIR}"
    cd ${TF_DIR} && {{cloud-provider}}_PROFILE=${PROFILE} terraform apply -auto-approve -input=false tfplan

destroy cloud-provider:
    #!/usr/bin/env bash
    just init {{cloud-provider}}
    PROFILE=$(just {{cloud-provider}}-profile)
    TF_DIR=$(just tf-unit-dir {{cloud-provider}})
    VAR_OPTIONS=$(just tf-options {{cloud-provider}})
    echo "[*] Destroying - Terraform Unit ${TF_DIR}"
    cd ${TF_DIR} && {{cloud-provider}}_PROFILE=${PROFILE} terraform destroy -auto-approve -input=false

plan-apply cloud-provider:
    #!/usr/bin/env bash
    just plan {{cloud-provider}}
    just apply {{cloud-provider}}

validate cloud-provider:
    #!/usr/bin/env bash
    echo "Validating {{cloud-provider}}..."
    cd {{cloud-provider}} && terraform validate

fmt cloud-provider:
    #!/usr/bin/env bash
    echo "Formatting {{cloud-provider}}..."
    cd {{cloud-provider}} && terraform fmt -recursive

lint cloud-provider:
    #!/usr/bin/env bash
    echo "Linting {{cloud-provider}}..."
    cd {{cloud-provider}} && terraform fmt -check -recursive

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

gen-docs:
    #!/usr/bin/env bash
    echo "Generate Terraform Docs"
    CP_DIR=$(just tf-cp-dir {{cloud-provider}})
    for dir in ${CP_DIR}/*;
    do 
        if [ -d "$dir" ]; 
            then (cd "$dir" && terraform-docs markdown table --output-file README.md --output-mode inject --config ../.terraform-docs.yaml .); 
        fi; 
    done
