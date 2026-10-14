# # # Attempt to create spot instance first if enabled
# resource "azurerm_linux_virtual_machine" "server" {
#   name                  = local.vm_name
#   location              = local.location
#   resource_group_name   = azurerm_resource_group.main.name
#   network_interface_ids = [azurerm_network_interface.main.id]
#   size                  = var.vm_size

#   # Admin account
#   admin_username = var.admin_username

#   admin_ssh_key {
#     username   = var.admin_username
#     public_key = file(pathexpand("~/.ssh/azure-omc-deploy-pc_key.pem.pub"))
#   }

#   # OS Disk
#   os_disk {
#     name                 = "${var.project_name}-osdisk-${random_string.suffix.result}"
#     caching              = "ReadWrite"
#     storage_account_type = var.os_disk_type
#     disk_size_gb         = var.os_disk_size
#   }

#   # Source image
#   source_image_reference {
#     publisher = var.image_publisher
#     offer     = var.image_offer
#     sku       = var.image_sku
#     version   = var.image_version
#   }

#   # User data script
#   user_data = base64encode(templatefile("${path.module}/user-data.sh", {
#     data_disk_device = "/dev/sdc"
#     data_mount_point = "/data"
#     admin_username   = var.admin_username
#   }))

#   # Managed identity
#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.main.id]
#   }

#   tags = local.tags
# }
