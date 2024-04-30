# Terraform Block

terraform {
  required_version = ">= 1.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}


#Provider Block

provider "azurerm" {
  features {}
}


# Resource Group
resource "azurerm_resource_group" "myrg1" {
  name     = "myrg-1"
  location = "eastus"
}

# Virtual Network
resource "azurerm_virtual_network" "myvnet2" {
  name                = "myvnet-2"
  resource_group_name = azurerm_resource_group.myrg1.name
  location            = azurerm_resource_group.myrg1.location
  address_space       = ["10.0.0.0/16"]

}

# CREATING SUBNETS
resource "azurerm_subnet" "websubnet" {
  name                 = "websubnet"
  address_prefixes     = ["10.0.15.0/24"]
  resource_group_name  = azurerm_resource_group.myrg1.name
  virtual_network_name = azurerm_virtual_network.myvnet2.name

}

resource "azurerm_subnet" "appsubnet" {
  name                 = "appsubnet"
  address_prefixes     = ["10.0.16.0/24"]
  resource_group_name  = azurerm_resource_group.myrg1.name
  virtual_network_name = azurerm_virtual_network.myvnet2.name

}

resource "azurerm_subnet" "dbsubnet" {
  name                 = "dbsubnet"
  address_prefixes     = ["10.0.17.0/24"]
  resource_group_name  = azurerm_resource_group.myrg1.name
  virtual_network_name = azurerm_virtual_network.myvnet2.name

}

# NSG
resource "azurerm_network_security_group" "mynsg" {
  name                = "mymainsec"
  location            = azurerm_resource_group.myrg1.location
  resource_group_name = azurerm_resource_group.myrg1.name
}

resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.app_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.appsubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

locals {
  app_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "120" : "8080",
    "130" : "22"
  }
}

## NSG Inbound Rule for AppTier Subnets
resource "azurerm_network_security_rule" "app_nsg_rule_inbound" {
  for_each                    = local.app_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg1.name
  network_security_group_name = azurerm_network_security_group.mynsg.name
}





