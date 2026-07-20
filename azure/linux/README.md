<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.60.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.60.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.vm_management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_network_security_group.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_security_group) | data source |
| [azurerm_resource_group.existing_network_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for the VM | `string` | `"azureuser"` | no |
| <a name="input_arm_client_id"></a> [arm\_client\_id](#input\_arm\_client\_id) | Azure Service Principal Client ID | `string` | n/a | yes |
| <a name="input_arm_client_secret"></a> [arm\_client\_secret](#input\_arm\_client\_secret) | Azure Service Principal Client Secret | `string` | n/a | yes |
| <a name="input_arm_subscription_id"></a> [arm\_subscription\_id](#input\_arm\_subscription\_id) | Azure Subscription ID | `string` | n/a | yes |
| <a name="input_arm_tenant_id"></a> [arm\_tenant\_id](#input\_arm\_tenant\_id) | Azure Tenant ID | `string` | n/a | yes |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Number of days to retain backups | `number` | `7` | no |
| <a name="input_backup_time"></a> [backup\_time](#input\_backup\_time) | Daily backup time (24-hour format) | `string` | `"23:00"` | no |
| <a name="input_backup_timezone"></a> [backup\_timezone](#input\_backup\_timezone) | Backup timezone | `string` | `"UTC"` | no |
| <a name="input_data_disk_iops"></a> [data\_disk\_iops](#input\_data\_disk\_iops) | Data disk IOPS (for Premium SSD) | `number` | `5000` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Data disk size in GB | `number` | `100` | no |
| <a name="input_data_disk_throughput"></a> [data\_disk\_throughput](#input\_data\_disk\_throughput) | Data disk throughput in MB/s (for Premium SSD) | `number` | `200` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_image_offer"></a> [image\_offer](#input\_image\_offer) | Offer of the VM image | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| <a name="input_image_publisher"></a> [image\_publisher](#input\_image\_publisher) | Publisher of the VM image | `string` | `"Canonical"` | no |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | SKU of the VM image | `string` | `"22_04-lts"` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | Version of the VM image | `string` | `"latest"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | `"chinanorth3"` | no |
| <a name="input_network_resource_group_name"></a> [network\_resource\_group\_name](#input\_network\_resource\_group\_name) | Name of existing resource group for network resources | `string` | n/a | yes |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | OS disk size in GB | `number` | `30` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | OS disk type | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used for resource naming | `string` | `"remote-ssh-vscode"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for resources | `string` | `"RG-SSH-REMOTE-VSCODE"` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of existing security group | `string` | n/a | yes |
| <a name="input_spot_instance"></a> [spot\_instance](#input\_spot\_instance) | Spot instance configuration | <pre>object({<br/>    enabled         = bool<br/>    eviction_policy = string # Deallocate or Delete<br/>    max_price       = string # Use -1 for maximum price<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "eviction_policy": "Deallocate",<br/>  "max_price": "-1"<br/>}</pre> | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to SSH public key file | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of existing subnet | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for resources | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size | `string` | `"Standard_B2s"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of existing virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_identity_id"></a> [managed\_identity\_id](#output\_managed\_identity\_id) | ID of the user-assigned managed identity |
| <a name="output_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#output\_managed\_identity\_principal\_id) | Principal ID of the managed identity |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group |
<!-- markdownlint-restore -->
<!-- END_TF_DOCS -->
