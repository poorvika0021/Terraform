#-------------------Resource Group for DB------------------------

resource "azurerm_resource_group" "db" {
  name     = "db"
  location = "eastus2"
}


#------------------------ MySql Flexible DB -------------------------------

resource "azurerm_mysql_flexible_server" "mysql_server" {
  name                   = "mysqlserver2313"
  resource_group_name    = azurerm_resource_group.db.name
  location               = azurerm_resource_group.db.location
  administrator_login    = "mysqladmin"
  administrator_password = "Admin@2313"
  sku_name               = "B_Standard_B1s"
}

resource "azurerm_mysql_flexible_database" "mysql_db" {
  name                = "mysqldb2313"
  resource_group_name = azurerm_resource_group.db.name
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

