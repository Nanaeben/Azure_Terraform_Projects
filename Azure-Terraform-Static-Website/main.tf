terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.12.0"
    }
  }
}
provider "azurerm" {
  features {

  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "terra-rg"
  location = "eastus"
}

#Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                     = "myghanaterraformwebsite"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }
}

#HTML Website
resource "azurerm_storage_blob" "blob" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "<h1>Terraform Website deployed on Azure</h1>"

}