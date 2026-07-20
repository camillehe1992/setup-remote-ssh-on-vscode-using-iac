# Data sources for current IP and existing resources
# Combine with a local that tries sources in order
data "http" "myip" {
  url = "https://checkip.amazonaws.com"

  # Set reasonable timeout
  request_timeout_ms = 3000
}

# Existing Resource Group for Network Resources
data "azurerm_resource_group" "existing_network_rg" {
  name = var.network_resource_group_name
}

# Existing Virtual Network
data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = var.network_resource_group_name
}

# Existing Subnet
data "azurerm_subnet" "existing" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.network_resource_group_name
}

# Existing Security Group
data "azurerm_network_security_group" "existing" {
  name                = var.security_group_name
  resource_group_name = var.network_resource_group_name
}
