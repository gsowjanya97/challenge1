resource  "azuread_application"  "terraform" {
display_name  =  "terraform"
}
 
data "azurerm_subscription" "primary" {
}
 
data "azurerm_client_config" "example" {
}

resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.example.object_id
}