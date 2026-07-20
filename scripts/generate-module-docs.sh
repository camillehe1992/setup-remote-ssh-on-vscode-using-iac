#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

declare -a module_dirs=()
run_all_modules=false

add_module_dir() {
    local module_dir="$1"

    for existing_dir in "${module_dirs[@]:-}"; do
        if [[ "${existing_dir}" == "${module_dir}" ]]; then
            return
        fi
    done

    module_dirs+=("${module_dir}")
}

discover_all_modules() {
    while IFS= read -r justfile_path; do
        local module_dir
        module_dir="$(dirname "${justfile_path}")"

        if compgen -G "${module_dir}/*.tf" > /dev/null; then
            add_module_dir "${module_dir#${REPO_ROOT}/}"
        fi
    done < <(find "${REPO_ROOT}" -mindepth 3 -maxdepth 3 -name justfile | sort)
}

resolve_module_dir() {
    local changed_path="$1"
    local search_dir

    search_dir="$(dirname "${changed_path}")"

    while [[ "${search_dir}" != "." && "${search_dir}" != "/" ]]; do
        if [[ -f "${REPO_ROOT}/${search_dir}/justfile" ]] && compgen -G "${REPO_ROOT}/${search_dir}/*.tf" > /dev/null; then
            printf '%s\n' "${search_dir}"
            return 0
        fi

        search_dir="$(dirname "${search_dir}")"
    done

    return 1
}

if [[ "$#" -eq 0 ]]; then
    run_all_modules=true
else
    for changed_path in "$@"; do
        if [[ "${changed_path}" == ".terraform-docs.yaml" ]]; then
            run_all_modules=true
            break
        fi

        if [[ "${changed_path}" != *.tf ]]; then
            continue
        fi

        if module_dir="$(resolve_module_dir "${changed_path}")"; then
            add_module_dir "${module_dir}"
        fi
    done
fi

if [[ "${run_all_modules}" == "true" ]]; then
    discover_all_modules
fi

if [[ "${#module_dirs[@]}" -eq 0 ]]; then
    echo "[*] No Terraform modules require documentation updates."
    exit 0
fi

echo "[*] Generating Terraform Docs for affected modules..."
for module_dir in "${module_dirs[@]}"; do
    echo "[*] Updating ${module_dir}/README.md"
    (
        cd "${REPO_ROOT}/${module_dir}"
        just gen-docs
    )
done
