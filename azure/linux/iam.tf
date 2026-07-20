# Managed Identity for the VM
resource "azurerm_user_assigned_identity" "main" {
  name                = "${var.project_name}-identity-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  tags                = local.tags
}

# Custom Role Definition for VM management
resource "azurerm_role_definition" "vm_management" {
  name        = "${var.project_name}-vm-management-${random_string.suffix.result}"
  scope       = azurerm_resource_group.main.id
  description = "Custom role for VM management operations"

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/networkInterfaces/write",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.main.id
  ]
}

# Role Assignment for the managed identity
resource "azurerm_role_assignment" "vm_management" {
  scope              = azurerm_resource_group.main.id
  role_definition_id = azurerm_role_definition.vm_management.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.main.principal_id
}

# Reader role for monitoring
resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}
