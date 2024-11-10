#-------------------Resource Group for DB------------------------

resource "azurerm_resource_group" "db" {
  name     = "db"
  location = "eastus2"
}


#----------------Postgres SQL ------------------------------

resource "azurerm_cosmosdb_postgresql_cluster" "postgressql" {
  name                            = "postgres-sql-cluster"
  resource_group_name             = azurerm_resource_group.db.name
  location                        = azurerm_resource_group.db.location
  administrator_login_password    = "Admin@2313"
  coordinator_storage_quota_in_mb = 131072
  coordinator_vcore_count         = 2
  node_count                      = 0
}

