# # Data disk for persistent storage
# resource "azurerm_managed_disk" "data" {
#   name                 = local.data_disk_name
#   location             = local.location
#   resource_group_name  = local.rg_name
#   storage_account_type = "Premium_LRS" # Equivalent to gp3 in AWS
#   create_option        = "Empty"
#   disk_size_gb         = var.data_disk_size

#   # Azure doesn't have direct gp3 equivalent, using Premium SSD with configured IOPS/throughput
#   disk_iops_read_write = var.data_disk_iops
#   disk_mbps_read_write = var.data_disk_throughput

#   tags = local.tags
# }

# # Attach data disk to VM
# resource "azurerm_virtual_machine_data_disk_attachment" "data" {
#   managed_disk_id    = azurerm_managed_disk.data.id
#   virtual_machine_id = local.vm.id
#   lun                = "10"
#   caching            = "ReadWrite"
# }
