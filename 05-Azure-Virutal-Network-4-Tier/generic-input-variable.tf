# Generic Input Variables
variable "business_division" {
  description = "Business Division in the large organization this infrastructure belongs to "
  type        = string
  default     = "sap"
}

# Environment Variables
variable "environment" {
  description = "Environment Variable used as a prefix"
  default     = "dev"
}

# Resource Group
variable "resource_group_name" {
  description = "Resource Group Name"
  default     = ""
}

# Azure Resource Location
variable "resource_group_location" {
  description = "Region in Azure where Resources will be allocated"
  default     = "eastus"
}

