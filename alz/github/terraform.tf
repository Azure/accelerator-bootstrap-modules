terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.2"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "azurerm" {
  subscription_id = var.bootstrap_subscription_id == "" ? null : var.bootstrap_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    storage {
      data_plane_available = false
    }
  }
  storage_use_azuread             = true
  resource_provider_registrations = "none"
  resource_providers_to_register = [
    "Microsoft.ContainerInstance",
    "Microsoft.ContainerRegistry",
    "Microsoft.ManagedIdentity",
    "Microsoft.Management",
    "Microsoft.Network",
    "Microsoft.Storage"
  ]
}

provider "github" {
  token = var.github_personal_access_token
  owner = var.github_organization_name
}
