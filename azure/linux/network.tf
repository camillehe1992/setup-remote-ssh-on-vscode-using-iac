# Public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.project_name}-pip-${random_string.suffix.result}"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.project_name}-${random_string.suffix.result}"
  tags                = local.tags
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.project_name}-nsg-${random_string.suffix.result}"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  # SSH rule with dynamic IP
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = [chomp(data.http.myip.response_body)]
    destination_address_prefix = "*"
  }

  # VS Code Server web interface (optional)
  security_rule {
    name                       = "VSCode-Web"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefixes    = [chomp(data.http.myip.response_body)]
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "${var.project_name}-nic-${random_string.suffix.result}"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
