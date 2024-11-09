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
#--------------------------------------------------------------------------

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
  name     = "terraform_rg"
}

resource "azurerm_container_registry" "tf_acr" {
  name                = "terraformreg1"
  resource_group_name = data.azurerm_resource_group.acr.name
  location            = data.azurerm_resource_group.acr.location
  sku                 = "Premium"
  admin_enabled       = true
}

output adminpwd {
value = azurerm_container_registry.tf_acr.admin_password
sensitive = true
}


