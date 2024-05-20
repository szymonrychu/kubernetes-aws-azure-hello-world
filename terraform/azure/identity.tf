resource "azurerm_user_assigned_identity" "test" {
  location            = var.location
  name                = "${var.environment_name}-identity"
  resource_group_name = azurerm_resource_group.this.name
}
