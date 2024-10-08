# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id   = "9112ff5f-1a9e-411d-b35f-4ec8bd46878a"
  tenant_id         = "3f03adac-fb8a-4ad6-b7a7-f73cc0f6fd0d"
  client_id         = "764fccda-d114-4bc9-9633-27a5258007d2"
  client_secret     = "pY28Q~W3hcXg1kD6k2~zuGA8oQlolqQOVsfWydsC"
}
