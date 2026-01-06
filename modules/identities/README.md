# Bootstrap Identities Module

This module creates User Assigned Managed Identities and their federated credentials for use in the Azure Landing Zones (ALZ) bootstrap process.

## Purpose

This module manages all identity resources needed for the ALZ accelerator bootstrap:
- Resource group for identities
- Plan and Apply user-assigned managed identities (for Terraform state management)
- Federated identity credentials (for workload identity federation with Azure DevOps/GitHub)
- Optional agent identity (for Container App Jobs with UAMI authentication)

## Usage

```hcl
module "identities" {
  source = "../../modules/identities"
  
  resource_group_name = "rg-identity-prod"
  location            = "eastus"
  
  managed_identities = {
    plan  = "uami-plan-prod"
    apply = "uami-apply-prod"
  }
  
  federated_credentials = {
    plan = {
      user_assigned_managed_identity_key = "plan"
      federated_credential_subject       = "sc://org/project/environment/plan"
      federated_credential_issuer        = "https://vstoken.dev.azure.com/..."
      federated_credential_name          = "fc-plan"
      audience                           = ["api://AzureADTokenExchange"]
    }
  }
  
  tags = {
    environment = "production"
  }
}
```

## Outputs

The module provides maps keyed by logical names for easy reference:
- `managed_identity_ids` - For passing to other modules
- `managed_identity_client_ids` - For authentication
- `managed_identity_principal_ids` - For role assignments
