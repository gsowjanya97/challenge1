terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.10.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}
provider "azurerm" {
    tenant_id = "23d3ff04-823e-42d1-b240-e290d28a66fb"
    features {}
}