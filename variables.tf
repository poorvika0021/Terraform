variable "rg_name" {
  default = "terraform_rg"
}

variable "rg_location" {
  default = "westus2"
}

variable "address_space" {
  default = ["10.1.0.0/16"]
  type    = list(string)
}

variable "vnet_name" {
  default = "vnet1"
}

variable "subnet_space" {
  default = ["10.1.0.0/24", "10.1.10.0/24"]
  type    = list(string)
}

variable "snet_name" {
  default = "terraform_snet"
}

variable "ssh_key" {
  default = "ssh_public_key"
}

variable "nic_name" {
  default = "terraform_nic"
}

variable "ip_name" {
  default = "terraform_ip"
}

variable "public_ip_name" {
  default = "pip"
}

variable "vm1_name" {
  default = "vm1"
}

variable "admin_username" {
  default = "vm1user"
}

variable "size" {
  default = "Standard_B1s"
}

variable "vm1_username" {
  default = "vm1user"
}

variable "sku_vm1" {
  default = "18.04-LTS"
}
#----------------------------------------------------
variable "vnet1_name" {
  default = "vnet2"
}
variable "rg1_location" {
  default = "eastus2"
}
variable "address_space1" {
  default = ["10.2.0.0/16"]
}

variable "snet1_name" {
  default = "terraform_snet1"
}

variable "subnet_space1" {
  default = ["10.2.0.0/24", "10.2.10.0/24"]
}

variable "pip_vm2" {
  default = "pip2"
}

variable "ip1_name" {
  default = "terraform_ip1"
}

variable "sku_vm2" {
  default = "2016-Datacenter"
}

variable "nic_wind_name" {
  default = "terraform_nic1"
}

variable "vm2_name" {
  default = "vm2"
}

variable "admin_password" {
  default = "Admin@password"
}

variable "nsg1_name" {
  default = "nsg1"
}

