# Azure Bastion Service - Resources
## Resource-1: Azure Bastion Subnet
resource "azurerm_subnet" "bastion_service_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.mybastionhostgrp.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefixes     = ["10.0.10.0/27"]
}

# Resource-2: Azure Bastion Public IP
resource "azurerm_public_ip" "bastion_service_publicip" {
  name                = "my-bastion-service-publicip"
  location            = azurerm_resource_group.mybastionhostgrp.location
  resource_group_name = azurerm_resource_group.mybastionhostgrp.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Resource-3: Azure Bastion Service Host
resource "azurerm_bastion_host" "bastion_host" {
  name                = "my-bastion-service"
  location            = azurerm_resource_group.mybastionhostgrp.location
  resource_group_name = azurerm_resource_group.mybastionhostgrp.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_service_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_service_publicip.id
  }
}