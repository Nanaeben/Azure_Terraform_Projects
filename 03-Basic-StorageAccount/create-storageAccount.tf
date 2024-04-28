terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "random_string" "random" {
  length  = 16
  special = false
  upper = false
}
 

resource "azurerm_resource_group" "myrg1" {
  name     = "myrg-1"
  location = "East US"
}

resource "azurerm_storage_account" "mySA1" {
  name                     = "mysa${random_string.random.id}"
  resource_group_name      = azurerm_resource_group.myrg1.name
  location                 = azurerm_resource_group.myrg1.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = {
    environment = "staging"
  }
}