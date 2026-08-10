# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local variables
locals {
  location       = var.location
  vm_name        = "${var.project_name}-vm-${random_string.suffix.result}"
  data_disk_name = "${var.project_name}-data-${random_string.suffix.result}"

  # Tags
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
}
