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
  use_private_networking          = var.use_self_hosted_agents && var.use_private_networking
  allow_storage_access_from_my_ip = local.use_private_networking && var.allow_storage_access_from_my_ip
}

locals {
  plan_key  = "plan"
  apply_key = "apply"
}

locals {
  ci_file_name          = "ci.yaml"
  cd_file_name          = "cd.yaml"
  ci_template_file_name = "ci-template.yaml"
  cd_template_file_name = "cd-template.yaml"
}

locals {
  target_subscriptions = distinct([var.subscription_id_connectivity, var.subscription_id_identity, var.subscription_id_management])
}

locals {
  managed_identities = {
    (local.plan_key)  = local.resource_names.user_assigned_managed_identity_plan
    (local.apply_key) = local.resource_names.user_assigned_managed_identity_apply
  }

  federated_credentials = {
    (local.plan_key) = {
      user_assigned_managed_identity_key = local.plan_key
      federated_credential_subject       = module.azure_devops.subjects[local.plan_key]
      federated_credential_issuer        = module.azure_devops.issuers[local.plan_key]
      federated_credential_name          = local.resource_names.user_assigned_managed_identity_federated_credentials_plan
    }
    (local.apply_key) = {
      user_assigned_managed_identity_key = local.apply_key
      federated_credential_subject       = module.azure_devops.subjects[local.apply_key]
      federated_credential_issuer        = module.azure_devops.issuers[local.apply_key]
      federated_credential_name          = local.resource_names.user_assigned_managed_identity_federated_credentials_apply
    }
  }

  agent_container_instances = var.use_self_hosted_agents ? {
    agent_01 = {
      container_instance_name = local.resource_names.container_instance_01
      agent_name              = local.resource_names.agent_01
      cpu                     = var.agent_container_cpu
      memory                  = var.agent_container_memory
      cpu_max                 = var.agent_container_cpu_max
      memory_max              = var.agent_container_memory_max
      zones                   = var.agent_container_zone_support ? ["1"] : []
    }
    agent_02 = {
      container_instance_name = local.resource_names.container_instance_02
      agent_name              = local.resource_names.agent_02
      cpu                     = var.agent_container_cpu
      memory                  = var.agent_container_memory
      cpu_max                 = var.agent_container_cpu_max
      memory_max              = var.agent_container_memory_max
      zones                   = var.agent_container_zone_support ? ["2"] : []
    }
  } : {}
}

locals {
  environments = {
    (local.plan_key) = {
      environment_name        = local.resource_names.version_control_system_environment_plan
      service_connection_name = local.resource_names.version_control_system_service_connection_plan
      service_connection_required_templates = [
        "${local.target_folder_name}/${local.ci_template_file_name}",
        "${local.target_folder_name}/${local.cd_template_file_name}"
      ]
    }
    (local.apply_key) = {
      environment_name        = local.resource_names.version_control_system_environment_apply
      service_connection_name = local.resource_names.version_control_system_service_connection_apply
      service_connection_required_templates = [
        "${local.target_folder_name}/${local.cd_template_file_name}"
      ]
    }
  }
}

locals {
  starter_module_folder_path      = var.module_folder_path_relative ? ("${path.module}/${var.module_folder_path}") : var.module_folder_path
  starter_root_module_folder_path = "${local.starter_module_folder_path}/${var.root_module_folder_relative_path}"
}

locals {
  agent_container_instance_dockerfile_url = "${var.agent_container_image_repository}#${var.agent_container_image_tag}:${var.agent_container_image_folder}"
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
