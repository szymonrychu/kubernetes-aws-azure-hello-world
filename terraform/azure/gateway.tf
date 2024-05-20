resource "azurerm_public_ip" "appgateway" {
  name                = "${var.environment_name}-appgateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

locals {
  frontend_ip_configuration_name = "${var.environment_name}-feip"
  backend_address_pool_name      = "${var.environment_name}-beap"
  backend_http_settings_name     = "${var.environment_name}-be-http"
  http_listener_name             = "${var.environment_name}-http"
  https_listener_name            = "${var.environment_name}-https"
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

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgateway.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = ["10.0.0.10"]
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  dynamic "http_listener" {
    for_each = var.ssl_certificate_name != null ? ["listener"] : []

    content {
      name                           = local.https_listener_name
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = "https"
      protocol                       = "Https"
      ssl_certificate_name           = var.ssl_certificate_name
    }
  }

  request_routing_rule {
    name                       = "${var.environment_name}-http"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  dynamic "request_routing_rule" {
    for_each = var.ssl_certificate_name != null ? ["routing"] : []

    content {
      name                       = "${var.environment_name}-https"
      rule_type                  = "Basic"
      http_listener_name         = local.https_listener_name
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = local.backend_http_settings_name
    }
  }

}
