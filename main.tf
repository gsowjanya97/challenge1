resource "azurerm_resource_group" "myrg" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_service_plan" "myapp" {
  name                = "myapp"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_windows_web_app" "mywebapp1428" {
  name                = "mywebapp1428"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  service_plan_id     = azurerm_service_plan.myapp.id

#Connecting Web App with SQL Server
    connection_string {
      name = "SQLConnection"
      type = "SQLAzure"
      value = "Data Source=tcp:${azurerm_mssql_server.webappdbserver200x23.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.webappdb200x23.name};User Id=${azurerm_mssql_server.webappdbserver200x23.administrator_login};Password='${azurerm_mssql_server.webappdbserver200x23.administrator_login_password}';"
    }

  site_config {
    application_stack {
        current_stack="dotnet"
        dotnet_version="v6.0"
    }
  }

#Monitoring of Web App
  logs {
    detailed_error_messages = true
    #Enabling Web Server Logging
    http_logs {
      azure_blob_storage {
        retention_in_days = 7
        sas_url = "https://${azurerm_storage_account.mystore200x23.name}.blob.core.windows.net/${azurerm_storage_container.logs.name}${data.azurerm_storage_account_blob_container_sas.mystoresas.sas}"
      }
    }
  }

  depends_on = [ azurerm_service_plan.myapp, azurerm_mssql_server.webappdbserver200x23, azurerm_mssql_database.webappdb200x23, azurerm_storage_account.mystore200x23 ]
}

#GitHub Integration
resource "azurerm_app_service_source_control" "gitcontrol" {
  app_id   = azurerm_windows_web_app.mywebapp1428.id
  repo_url = "https://github.com/gsowjanya97/challenge1"
  branch   = "master"
  use_manual_integration = true
}

#Storage for Web App monitoring logs
resource "azurerm_storage_account" "mystore200x23" {
  name                     = "mystore200x23"
  resource_group_name      = azurerm_resource_group.myrg.name
  location                 = azurerm_resource_group.myrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [azurerm_resource_group.myrg]
}

resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.mystore200x23.name
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.mystore200x23 ]
}

data "azurerm_storage_account_blob_container_sas" "mystoresas" {
  connection_string = azurerm_storage_account.mystore200x23.primary_connection_string
  container_name    = azurerm_storage_container.logs.name
  https_only        = true

  start  = "2023-09-28"
  expiry = "2023-10-28"

  permissions {
    read   = true
    add    = true
    create = false
    write  = true
    delete = true
    list   = true
  }

  depends_on = [ azurerm_storage_account.mystore200x23]
}

#Authentication of Web App to Storage Account via Shared Access Secret
output "sas_value" {
  value=nonsensitive("https://${azurerm_storage_account.mystore200x23.name}.blob.core.windows.net/${azurerm_storage_container.logs.name}${data.azurerm_storage_account_blob_container_sas.mystoresas.sas}")
}