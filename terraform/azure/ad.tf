# # resource "azuread_group" "example" {
# #   display_name     = "example"
# #   owners           = [data.azuread_client_config.current.object_id]
# #   security_enabled = true
# # }

# data "azuread_directory_role" "aks" {
#   display_name = "Azure Kubernetes Service Cluster User Role"
# }

# resource "azuread_directory_role_assignment" "example" {
#   role_id             = data.azuread_directory_role.aks.template_id
#   principal_object_id = module.aks.aks_id
#   directory_scope_id  = format("/%s", azuread_application.example.object_id)
# }

# data "azuread_directory_roles" "current" {}




# # data "azuread_user" "example" {
# #   user_principal_name = "jdoe@hashicorp.com"
# # }

# # resource "azuread_directory_role" "example" {
# #   display_name = "Security administrator"
# # }

# # resource "azuread_directory_role_assignment" "example" {
# #   role_id             = data.azuread_directory_role.aks.template_id
# #   principal_object_id = data.azuread_user.example.object_id
# # }








# # resource "azuread_directory_role" "example" {
# #   display_name = "Cloud application administrator"
# # }

# # resource "azuread_application" "example" {
# #   display_name = "My Application"
# # }

# # data "azuread_user" "example" {
# #   user_principal_name = "jdoe@hashicorp.com"
# # }
