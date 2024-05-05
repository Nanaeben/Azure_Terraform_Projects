# terraform {
#   required_version = ">= 1.8"
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = ">= 3.0"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = ">= 3.0"
#     }
#     null = {
#       source  = "hashicorp/null"
#       version = ">= 3.0"
#     }
#   }
# }

# terraform {
#   required_version = ">= 1.8"
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = ">= 3.0"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = ">= 3.0"
#     }
#     null = {
#       source  = "hashicorp/null"
#       version = ">= 3.0"
#     }
#   }
# }

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}


provider "azurerm" {
  features {}
}