#-------------------Resource Group for DB------------------------

resource "azurerm_resource_group" "db" {
  name     = "db"
  location = "eastus2"
}

#--------------------Creating COSMOS DB-------------------------

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "tf-cosmos-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.db.location
  resource_group_name = azurerm_resource_group.db.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  automatic_failover_enabled = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  geo_location {
    location          = azurerm_resource_group.db.location
    failover_priority = 0
  }

  geo_location {
    location          = "westus"
    failover_priority = 1
  }
}


#-------------------Mongo DB---------------------------------------

resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "tf-cosmos-mongo-db"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
}

