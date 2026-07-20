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
    set -euo pipefail
    echo "[*] Generating Terraform Docs for all Terraform modules..."
    while IFS= read -r module_dir; do
        relative_module_dir="${module_dir#"{{PROJECT_ROOT}}"/}"
        echo "[*] Updating module docs for ${relative_module_dir}"
        (
            cd "${module_dir}"
            just gen-docs
        )
    done < <(find "{{PROJECT_ROOT}}" -mindepth 3 -maxdepth 3 -name justfile -exec dirname {} \; | sort)
