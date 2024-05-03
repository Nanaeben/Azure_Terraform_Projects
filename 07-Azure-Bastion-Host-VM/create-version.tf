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
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}


#Provider Block
provider "azurerm" {
  features {}
}


# Resource Group
resource "azurerm_resource_group" "mybastionhostgrp" {
  name     = "orl-mybastionhostgrp"
  location = "eastus"
}