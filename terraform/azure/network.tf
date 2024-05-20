resource "azurerm_network_security_group" "web" {
  name                = "${var.environment_name}-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "allow-80-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-443-all"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ephenermals"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200 - 65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "app" {
  name                = "${var.environment_name}-app"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  # Allow SSH traffic in from public subnet to private subnet.
  security_rule {
    name                       = "allow-ssh-public-subnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.websubnetcidr
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_public_ip" "nat" {
  name                = "${var.environment_name}-nat"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_nat_gateway" "natgateway" {
  name                    = "nat-Gateway"
  location                = var.location
  resource_group_name     = azurerm_resource_group.this.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_subnet_nat_gateway_association" "natgateway" {
  subnet_id      = lookup(module.vnet.vnet_subnets_name_id, "app")
  nat_gateway_id = azurerm_nat_gateway.natgateway.id
}

resource "azurerm_nat_gateway_public_ip_association" "natipassoc" {
  nat_gateway_id       = azurerm_nat_gateway.natgateway.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "~> 4.1"

  resource_group_name = azurerm_resource_group.this.name
  use_for_each        = true
  address_space       = [var.vnetcidr]
  subnet_prefixes     = [var.appsubnetcidr, var.websubnetcidr]
  subnet_names        = ["app", "web"]
  vnet_location       = var.location

  nsg_ids = {
    web = azurerm_network_security_group.web.id
    app = azurerm_network_security_group.app.id
  }

  subnet_enforce_private_link_endpoint_network_policies = {
    app = true
  }

  subnet_service_endpoints = {
    app = ["Microsoft.AzureActiveDirectory"]
  }

  tags = var.tags
}
