# Resource Name Setup
locals {
  resource_names = module.resource_names.resource_names
}

# Dynamic Bicep Configuration Path
locals {
  bicep_config_file_path = var.bicep_config_file_path != null ? var.bicep_config_file_path : (
    var.iac_type == "bicep-avm" ? ".config/ALZ-Powershell.config.json" :
    "accelerator/.config/ALZ-Powershell-Auto.config.json"
  )
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
  target_subscriptions_legacy = distinct([var.subscription_id_connectivity, var.subscription_id_identity, var.subscription_id_management])
  target_subscriptions        = length(var.subscription_ids) > 0 ? distinct(values(var.subscription_ids)) : local.target_subscriptions_legacy
}

locals {
  managed_identities = {
    (local.plan_key)  = local.resource_names.user_assigned_managed_identity_plan
    (local.apply_key) = local.resource_names.user_assigned_managed_identity_apply
  }

  federated_credentials = var.federated_credentials
}

locals {
  starter_module_folder_path      = var.module_folder_path_relative ? ("${path.module}/${var.module_folder_path}") : var.module_folder_path
  starter_root_module_folder_path = "${local.starter_module_folder_path}/${var.root_module_folder_relative_path}"
}

locals {
  target_directory = var.target_directory == "" ? ("${path.module}/${var.default_target_directory}") : var.target_directory
}

locals {
  custom_role_definitions_bicep_names     = { for key, value in var.custom_role_definitions_bicep : "custom_role_definition_bicep_${key}" => value.name }
  custom_role_definitions_terraform_names = { for key, value in var.custom_role_definitions_terraform : "custom_role_definition_terraform_${key}" => value.name }

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
}

locals {
  architecture_definition_name             = var.architecture_definition_name
  has_architecture_definition              = var.architecture_definition_name != null && var.architecture_definition_name != ""
  architecture_definition_file_destination = var.architecture_definition_name != null && var.architecture_definition_name != "" ? "${local.target_directory}/${var.root_module_folder_relative_path}/lib/architecture_definitions/${local.architecture_definition_name}.alz_architecture_definition.json" : ""
}
