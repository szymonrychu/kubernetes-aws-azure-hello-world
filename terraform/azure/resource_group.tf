resource "azurerm_resource_group" "this" {
  name     = var.environment_name
  location = var.location
}
