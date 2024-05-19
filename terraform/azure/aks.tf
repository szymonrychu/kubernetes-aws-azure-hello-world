module "aks" {
  source  = "Azure/aks/azurerm"
  version = "~> 8.0"

  prefix                               = "prefix"
  resource_group_name                  = azurerm_resource_group.this.name
  admin_username                       = null
  azure_policy_enabled                 = true
  cluster_log_analytics_workspace_name = "${var.environment_name}-test"
  cluster_name                         = "${var.environment_name}-test"
  identity_ids                         = [azurerm_user_assigned_identity.test.id]
  identity_type                        = "UserAssigned"
  vnet_subnet_id                       = lookup(module.vnet.vnet_subnets_name_id, "app")
  os_disk_size_gb                      = 60

  network_plugin = "azure"


  maintenance_window = {
    allowed = [
      {
        day   = "Sunday",
        hours = [22, 23]
      },
    ]
    not_allowed = []
  }
  net_profile_dns_service_ip = "10.2.0.2"
  net_profile_service_cidr   = "10.2.0.0/16"
  rbac_aad                   = false
  # role_based_access_control_enabled = true

  brown_field_application_gateway_for_ingress = {
    id        = azurerm_application_gateway.network.id
    subnet_id = lookup(module.vnet.vnet_subnets_name_id, "web")
  }
  create_role_assignments_for_application_gateway = true
  local_account_disabled                          = false
}
