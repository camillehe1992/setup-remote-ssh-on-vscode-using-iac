# justfile - Task runner for Terraform workflows

# Project root directory (where the justfile is located)
PROJECT_ROOT := `pwd`

# Shell to use
set shell := ["bash", "-uc"]
set dotenv-load := true
set positional-arguments

# Delegate AWS workflows while keeping aws/justfile as the implementation.
aws *args:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "$#" -eq 0 ]; then
        echo "Usage: just aws <recipe> [arguments]" >&2
        exit 2
    fi
    exec just --justfile "{{PROJECT_ROOT}}/aws/justfile" \
        --working-directory "{{PROJECT_ROOT}}/aws" "$@"

versions:
    #!/usr/bin/env bash
    echo "Show version information for installed tools..."
    echo "Terraform version: $(terraform version)"
    echo "markdownlint-cli version: $(markdownlint --version)"
    echo "pre-commit version: $(pre-commit -V)"
    echo "checkov version: $(checkov --version)"
    echo "trivy version: $(trivy --version)"
    # Install CLI for cloud providers as needed
    echo "AWS version $(aws --version | head -n 1)"
    echo "Azure version $(az --version | head -n 1)"
    echo "AliCloud version $(aliyun --version | head -n 1)"

# ------------------------------------------------------------------------------
# Core commands
# ------------------------------------------------------------------------------

install-hooks:
    #!/usr/bin/env bash
    echo "[*] Installing pre-commit hooks"
    pip install pre-commit
    echo "[*] Pre-commit installed"
    pre-commit install --hook-type pre-commit --hook-type pre-push --hook-type commit-msg
    echo "[*] Pre-commit hooks installed"
