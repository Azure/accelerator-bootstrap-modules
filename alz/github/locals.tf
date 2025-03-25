# Resource Name Setup
locals {
  resource_names = module.resource_names.resource_names
}

locals {
  root_parent_management_group_id = var.root_parent_management_group_id == "" ? data.azurerm_client_config.current.tenant_id : var.root_parent_management_group_id
}

locals {
  enterprise_plan = "enterprise"
}

locals {
  iac_terraform = "terraform"
}

locals {
  use_private_networking          = var.use_self_hosted_runners && var.use_private_networking
  allow_storage_access_from_my_ip = local.use_private_networking && var.allow_storage_access_from_my_ip
}

locals {
  use_runner_group                   = var.use_runner_group && module.github.organization_plan == local.enterprise_plan && var.use_self_hosted_runners
  runner_organization_repository_url = local.use_runner_group ? local.github_organization_url : "${local.github_organization_url}/${module.github.repository_names.module}"
}

locals {
  plan_key  = "plan"
  apply_key = "apply"
}

locals {
  ci_template_file_name = "workflows/ci-template.yaml"
  cd_template_file_name = "workflows/cd-template.yaml"
}

locals {
  target_subscriptions = distinct([var.subscription_id_connectivity, var.subscription_id_identity, var.subscription_id_management])
}

locals {
  environments = {
    (local.plan_key)  = local.resource_names.version_control_system_environment_plan
    (local.apply_key) = local.resource_names.version_control_system_environment_apply
  }
}

locals {
  managed_identities = {
    (local.plan_key)  = local.resource_names.user_assigned_managed_identity_plan
    (local.apply_key) = local.resource_names.user_assigned_managed_identity_apply
  }

  federated_credentials = { for key, value in module.github.subjects :
    key => {
      user_assigned_managed_identity_key = value.user_assigned_managed_identity_key
      federated_credential_subject       = value.subject
      federated_credential_issuer        = module.github.issuer
      federated_credential_name          = "${local.resource_names.user_assigned_managed_identity_federated_credentials_prefix}-${key}"
    }
  }

  runner_container_instances = var.use_self_hosted_runners ? {
    agent_01 = {
      container_instance_name = local.resource_names.container_instance_01
      agent_name              = local.resource_names.runner_01
      cpu                     = var.runner_container_cpu
      memory                  = var.runner_container_memory
      cpu_max                 = var.runner_container_cpu_max
      memory_max              = var.runner_container_memory_max
      zones                   = var.runner_container_zone_support ? ["1"] : []
    }
    agent_02 = {
      container_instance_name = local.resource_names.container_instance_02
      agent_name              = local.resource_names.runner_02
      cpu                     = var.runner_container_cpu
      memory                  = var.runner_container_memory
      cpu_max                 = var.runner_container_cpu_max
      memory_max              = var.runner_container_memory_max
      zones                   = var.runner_container_zone_support ? ["2"] : []
    }
  } : {}
}

locals {
  starter_module_folder_path      = var.module_folder_path_relative ? ("${path.module}/${var.module_folder_path}") : var.module_folder_path
  starter_root_module_folder_path = "${local.starter_module_folder_path}/${var.root_module_folder_relative_path}"
}

locals {
  runner_container_instance_dockerfile_url = "${var.runner_container_image_repository}#${var.runner_container_image_tag}:${var.runner_container_image_folder}"
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
  architecture_definition_name = var.architecture_definition_name
  has_architecture_definition  = var.architecture_definition_name != null && var.architecture_definition_name != ""
}

locals {
  github_organization_url = "${var.github_organization_scheme}://${var.github_organization_domain_name}/${var.github_organization_name}"
  github_api_base_url     = var.github_api_domain_name == "" ? "${var.github_organization_scheme}://api.${var.github_organization_domain_name}/" : "${var.github_organization_scheme}://${var.github_api_domain_name}/"
}
