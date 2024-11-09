#-------------------Resource Group ------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

#----------------------------Virtual Network ------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
}

#-------------------Subnet------------------------

resource "azurerm_subnet" "snet" {
  name                 = var.snet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_space
}

#-------------------Public SSH ------------------------

resource "azurerm_ssh_public_key" "ssh" {
  name                = var.ssh_key
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg_location
  public_key          = file("~/.ssh/id_rsa.pub")
}

#-------------------------PublicIp-----------------------

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg_location
  allocation_method   = "Static"
}

#----------------------NIC-------------------------------

resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg_location
  ip_configuration {
    name                          = var.ip_name
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.snet.id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

#--------------------------Linux Virtual Machine --------------------------------------

resource "azurerm_linux_virtual_machine" "vm1" {
  name                  = var.vm1_name
  resource_group_name   = var.rg_name
  location              = var.rg_location
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.size
  admin_ssh_key {
    public_key = file("~/.ssh/id_rsa.pub")
    username   = var.vm1_username
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.sku_vm1
    version   = "latest"
  }
}

#----------------------------Windows Virtual Machine -----------------------

resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet1_name
  location            = var.rg1_location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space1
}
resource "azurerm_subnet" "snet1" {
  name                 = var.snet1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = var.subnet_space1
}

resource "azurerm_public_ip" "pip_vm2" {
  name                = var.pip_vm2
  location            = var.rg1_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nicwind" {
  name                = var.nic_wind_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg1_location
  ip_configuration {
    name                          = var.ip1_name
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.snet1.id
  }
}


resource "azurerm_windows_virtual_machine" "vm2" {
  name                  = var.vm2_name
  resource_group_name   = var.rg_name
  location              = var.rg1_location
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nicwind.id]
  size                  = var.size

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.sku_vm2
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name                = var.nsg1_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg_location
  security_rule {
    name                       = "sshport"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#------------------------ACR -----------------------

data "azurerm_resource_group" "acr" {
  name = "terraform_rg"
}

resource "azurerm_container_registry" "tf_acr" {
  name                = "terraformreg1"
  resource_group_name = data.azurerm_resource_group.acr.name
  location            = data.azurerm_resource_group.acr.location
  sku                 = "Premium"
  admin_enabled       = true
}

output "adminpwd" {
  value     = azurerm_container_registry.tf_acr.admin_password
  sensitive = true
}

#--------------------Scope map and tokens ----------------------------

resource "azurerm_container_registry_token" "token" {
  name                    = "tftoken1"
  container_registry_name = azurerm_container_registry.tf_acr.name
  resource_group_name     = data.azurerm_resource_group.acr.name
  scope_map_id            = data.azurerm_container_registry_scope_map.scope.id

  depends_on = [data.azurerm_container_registry_scope_map.scope]
}

data "azurerm_container_registry_scope_map" "scope" {
  name                    = "_repositories_pull"
  resource_group_name     = data.azurerm_resource_group.acr.name
  container_registry_name = azurerm_container_registry.tf_acr.name
}

resource "azurerm_container_registry_token_password" "pwd" {
  container_registry_token_id = azurerm_container_registry_token.token.id
  password1 {
    expiry = "2025-11-02T17:57:36+08:00"
  }
}

#------------------Domain name System (DNS)------------------------

resource "azurerm_dns_zone" "dns1" {
  name                = "domain1.com"
  resource_group_name = azurerm_resource_group.rg.name
}

#---------------------Private DNS ----------------------------

resource "azurerm_private_dns_zone" "pdns" {
  name                = "terraform_pdns.com"
  resource_group_name = azurerm_resource_group.rg.name
}


#---------------------Attaching Virtual network to private DNS -----------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "pdns_vnet1" {
  name                  = "pdns_vnet1"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}


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
    location          = "northeurope"
    failover_priority = 1
 }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
}

