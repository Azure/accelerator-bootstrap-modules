terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}
