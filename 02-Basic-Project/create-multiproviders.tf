terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.0.0"
    }
  }
}

# Initial Provider - Provider 1
provider "azurerm" {
  features {
    
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = false
    }
  }
  alias = "provider2-westus"
}

resource "azurerm_resource_group" "myrg1" {
    name = "myRG-1"
    location = "East US"
  
}

resource "azurerm_resource_group" "myrg2" {
    name = "myRG-2"
    location = "West US"
  provider = azurerm.provider2-westus
}