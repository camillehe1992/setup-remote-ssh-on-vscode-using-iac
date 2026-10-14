# AWS Ubuntu Terraform

Place Ubuntu-specific Terraform files in this directory.

## Notes

- Keep module-local files self-contained under `aws/ubuntu/terraform/`.
- If the module needs a `user_data.sh`, keep it in this directory and reference it from Terraform with `file("${path.module}/user_data.sh")`.
