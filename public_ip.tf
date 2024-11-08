resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "snet" {
  name                 = var.snet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_space
}

resource "azurerm_ssh_public_key" "ssh" {
  name                = var.ssh_key
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg_location
  public_key          = file("~/.ssh/id_rsa.pub")
}

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg_location
  allocation_method   = "Static"
}


