# # VM Information
# output "vm_id" {
#   description = "ID of the created VM"
#   value       = azurerm_linux_virtual_machine.server.id
# }

# output "vm_name" {
#   description = "Name of the created VM"
#   value       = azurerm_linux_virtual_machine.server.name
# }

# output "vm_priority" {
#   description = "Priority type of the VM (Spot/Regular)"
#   value       = local.vm.priority
# }

# # Network Information
# output "public_ip_address" {
#   description = "Public IP address of the VM"
#   value       = azurerm_public_ip.main.ip_address
# }

# output "public_ip_fqdn" {
#   description = "Fully qualified domain name of the public IP"
#   value       = azurerm_public_ip.main.fqdn
# }

# output "private_ip_address" {
#   description = "Private IP address of the VM"
#   value       = local.vm.private_ip_address
# }

# # SSH Connection Commands
# output "ssh_command" {
#   description = "SSH command to connect to the VM"
#   value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
# }

# output "ssh_command_with_fqdn" {
#   description = "SSH command using FQDN to connect to the VM"
#   value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.fqdn}"
# }

# # VS Code Server Access
# output "vscode_server_url" {
#   description = "URL to access VS Code Server (if running)"
#   value       = "http://${azurerm_public_ip.main.ip_address}:8080"
# }

# output "vscode_server_url_fqdn" {
#   description = "URL with FQDN to access VS Code Server"
#   value       = "http://${azurerm_public_ip.main.fqdn}:8080"
# }

# # Data Disk Information
# output "data_disk_id" {
#   description = "ID of the data disk"
#   value       = azurerm_managed_disk.data.id
# }

# output "data_disk_size_gb" {
#   description = "Size of the data disk in GB"
#   value       = azurerm_managed_disk.data.disk_size_gb
# }

# output "data_mount_point" {
#   description = "Mount point for the data disk"
#   value       = "/data"
# }

# # Backup Information
# output "backup_vault_id" {
#   description = "ID of the Recovery Services Vault"
#   value       = azurerm_recovery_services_vault.main.id
# }

# output "backup_policy_id" {
#   description = "ID of the backup policy"
#   value       = azurerm_backup_policy_vm.daily.id
# }

# Managed Identity
output "managed_identity_id" {
  description = "ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.main.principal_id
}

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

# # Connection Commands Combined
# output "connection_info" {
#   description = "Complete connection information"
#   value       = <<-EOT
#     === VS Code Remote Development VM ===

#     SSH Connection:
#       ${var.admin_username}@${azurerm_public_ip.main.ip_address}
#       ${var.admin_username}@${azurerm_public_ip.main.fqdn}

#     VS Code Server Access:
#       http://${azurerm_public_ip.main.ip_address}:8080
#       http://${azurerm_public_ip.main.fqdn}:8080

#     Data Disk:
#       Mount point: /data
#       Size: ${azurerm_managed_disk.data.disk_size_gb} GB

#     VM Type: ${local.vm.priority}

#     Backup Schedule: Daily at ${var.backup_time} ${var.backup_timezone}
#     Backup Retention: ${var.backup_retention_days} days
#   EOT
# }
