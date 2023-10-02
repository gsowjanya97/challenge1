resource "azurerm_mssql_server" "webappdbserver200x23" {
  name                         = "webappdbserver200x23"
  resource_group_name          = local.resource_group_name
  location                     = local.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Sowjanya@123"

 depends_on = [ azurerm_resource_group.myrg ]
}

resource "azurerm_mssql_database" "webappdb200x23" {
  name           = "webappdb200x23"
  server_id      = azurerm_mssql_server.webappdbserver200x23.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"

  depends_on = [ azurerm_mssql_server.webappdbserver200x23 ]
}

#Firewall rule to allow Web App to connect to SQL Server
resource "azurerm_mssql_firewall_rule" "AllowWebApp" {
  name             = "AllowWebApp"
  server_id        = azurerm_mssql_server.webappdbserver200x23.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
  depends_on = [ azurerm_mssql_server.webappdbserver200x23 ]
}

#Adding Table in SQL Server
resource "null_resource" "sqltable" {
  provisioner "local-exec" {
    command = "sqlcmd -S ${azurerm_mssql_server.webappdbserver200x23.fully_qualified_domain_name} -U ${azurerm_mssql_server.webappdbserver200x23.administrator_login} -P ${azurerm_mssql_server.webappdbserver200x23.administrator_login_password} -d ${azurerm_mssql_database.webappdb200x23.name} -i Table.sql"
  }
  depends_on = [ azurerm_mssql_database.webappdb200x23 ]
}