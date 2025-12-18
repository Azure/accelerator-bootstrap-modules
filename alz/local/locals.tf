# Resource Name Setup
locals {
  resource_names = module.resource_names.resource_names
}

locals {
  root_parent_management_group_id = var.root_parent_management_group_id == "" ? data.azurerm_client_config.current.tenant_id : var.root_parent_management_group_id
}

locals {
  iac_terraform = "terraform"
}

locals {
  plan_key  = "plan"
  apply_key = "apply"
}

locals {
  target_subscriptions = distinct(values(var.subscription_ids))
}

locals {
  managed_identities = {
    (local.plan_key)  = local.resource_names.user_assigned_managed_identity_plan
    (local.apply_key) = local.resource_names.user_assigned_managed_identity_apply
  }

  federated_credentials = var.federated_credentials
}

locals {
  starter_module_folder_path = var.module_folder_path_relative ? ("${path.module}/${var.module_folder_path}") : var.module_folder_path
}

locals {
  target_directory          = var.target_directory == "" ? ("${path.module}/${var.default_target_directory}") : var.target_directory
  script_target_folder_name = "scripts"
  script_source_folder_name = var.iac_type == "bicep" ? "scripts-bicep" : (var.iac_type == "bicep-classic" ? "scripts" : null)
  script_source_folder_path = local.script_source_folder_name == null ? null : "${path.module}/${local.script_source_folder_name}"
}

locals {
  custom_role_definitions_bicep_names         = { for key, value in var.custom_role_definitions_bicep : "custom_role_definition_bicep_${key}" => value.name }
  custom_role_definitions_terraform_names     = { for key, value in var.custom_role_definitions_terraform : "custom_role_definition_terraform_${key}" => value.name }
  custom_role_definitions_bicep_classic_names = { for key, value in var.custom_role_definitions_bicep_classic : "custom_role_definition_bicep_classic_${key}" => value.name }

  custom_role_definitions_bicep = {
    for key, value in var.custom_role_definitions_bicep : key => {
      name        = local.resource_names["custom_role_definition_bicep_${key}"]
      description = value.description
      permissions = value.permissions
    }
  }

  custom_role_definitions_terraform = {
    for key, value in var.custom_role_definitions_terraform : key => {
      name        = local.resource_names["custom_role_definition_terraform_${key}"]
      description = value.description
      permissions = value.permissions
    }
  }

  custom_role_definitions_bicep_classic = {
    for key, value in var.custom_role_definitions_bicep_classic : key => {
      name        = local.resource_names["custom_role_definition_bicep_classic_${key}"]
      description = value.description
      permissions = value.permissions
    }
  }
}
