resource "azurerm_public_ip" "appgateway" {
  name                = "${var.environment_name}-appgateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.environment_name}-appgateway"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.environment_name}-ip-configuration"
    subnet_id = lookup(module.vnet.vnet_subnets_name_id, "web")
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.environment_name}-feip"
    public_ip_address_id = azurerm_public_ip.appgateway.id
  }

  backend_address_pool {
    name         = "${var.environment_name}-beap"
    ip_addresses = ["10.0.0.10"]
  }

  backend_http_settings {
    name                  = "${var.environment_name}-be-htst"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "${var.environment_name}-httplstn"
    frontend_ip_configuration_name = "${var.environment_name}-feip"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.environment_name}-rqrt"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "${var.environment_name}-httplstn"
    backend_address_pool_name  = "${var.environment_name}-beap"
    backend_http_settings_name = "${var.environment_name}-be-htst"
  }
}
