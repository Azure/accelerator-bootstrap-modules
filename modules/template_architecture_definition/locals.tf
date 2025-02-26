locals {
  # Determine template architecture definition inputs from starter module tfvars
  starter_module_tfvars                  = jsondecode(file("${var.starter_module_folder_path}/terraform.tfvars.json"))
  default_prefix                         = try(local.starter_module_tfvars.default_prefix, "alz")
  optional_postfix                       = try(local.starter_module_tfvars.optional_postfix, "")
  management_group_configuration         = try(local.starter_module_tfvars.management_group_configuration, {})
  platform_management_group_children     = try(local.starter_module_tfvars.platform_management_group_children, {})
  landing_zone_management_group_children = try(local.starter_module_tfvars.landing_zone_management_group_children, {})
  default_template_file_path             = "${path.module}/templates/architecture_definition.json.tftpl"
  template_file_path                     = var.architecture_definition_template_path != "" ? var.architecture_definition_template_path : local.default_template_file_path

  # Customer has provided a custom architecture definition
  has_architecture_definition_override = var.architecture_definition_override_path != ""

  # ALZ archetypes
  alz_root_archtype           = ["root"]
  alz_platform_archtype       = ["platform"]
  alz_landing_zone_archtype   = ["landing_zones"]
  alz_decommissioned_archtype = ["decommissioned"]
  alz_sandboxes_archtype      = ["sandbox"]
  alz_management_archtype     = ["management"]
  alz_connectivity_archtype   = ["connectivity"]
  alz_identity_archtype       = ["identity"]
  alz_corp_archtype           = ["corp"]
  alz_online_archtype         = ["online"]

  # Management group configuration archetypes
  config_root_archtypes                = try(local.management_group_configuration.root.archetypes, [])
  config_platform_archtypes            = try(local.management_group_configuration.platform.archetypes, [])
  config_landingzones_archtypes        = try(local.management_group_configuration.landingzones.archetypes, [])
  config_decommissioned_archtypes      = try(local.management_group_configuration.decommissioned.archetypes, [])
  config_sandbox_archtypes             = try(local.management_group_configuration.sandbox.archetypes, [])
  config_management_archtypes          = try(local.management_group_configuration.management.archetypes, [])
  config_connectivity_archtypes        = try(local.management_group_configuration.connectivity.archetypes, [])
  config_identity_archtypes            = try(local.management_group_configuration.identity.archetypes, [])
  config_corp_archtypes                = try(local.management_group_configuration.corp.archetypes, [])
  config_online_archtypes              = try(local.management_group_configuration.online.archetypes, [])
  config_confidential_corp_archtypes   = try(local.management_group_configuration.confidential_corp.archetypes, [])
  config_confidential_online_archtypes = try(local.management_group_configuration.confidential_online.archetypes, [])

  # management group layered archetypes
  root_archtypes                = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_root_archtype, local.config_root_archtypes) : local.config_root_archtypes
  platform_archtypes            = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_platform_archtype, local.config_platform_archtypes) : local.config_platform_archtypes
  landingzones_archtypes        = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_landing_zone_archtype, local.config_landingzones_archtypes) : local.config_landingzones_archtypes
  decommissioned_archtypes      = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_decommissioned_archtype, local.config_decommissioned_archtypes) : local.config_decommissioned_archtypes
  sandbox_archtypes             = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_sandboxes_archtype, local.config_sandbox_archtypes) : local.config_sandbox_archtypes
  management_archtypes          = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_management_archtype, local.config_management_archtypes) : local.config_management_archtypes
  connectivity_archtypes        = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_connectivity_archtype, local.config_connectivity_archtypes) : local.config_connectivity_archtypes
  identity_archtypes            = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_identity_archtype, local.config_identity_archtypes) : local.config_identity_archtypes
  corp_archtypes                = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_corp_archtype, local.config_corp_archtypes) : local.config_corp_archtypes
  online_archtypes              = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_online_archtype, local.config_online_archtypes) : local.config_online_archtypes
  confidential_corp_archtypes   = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_corp_archtype, local.config_confidential_corp_archtypes) : local.config_confidential_corp_archtypes
  confidential_online_archtypes = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_online_archtype, local.config_confidential_online_archtypes) : local.config_confidential_online_archtypes

  management_group_format_variables = {
    default_prefix   = local.default_prefix
    optional_postfix = local.optional_postfix
  }

  root_management_group_id                = try(templatestring(local.management_group_configuration.root.id, local.management_group_format_variables), "")
  platform_management_group_id            = try(templatestring(local.management_group_configuration.platform.id, local.management_group_format_variables), "")
  landing_zone_management_group_id        = try(templatestring(local.management_group_configuration.landingzones.id, local.management_group_format_variables), "")
  decommissioned_management_group_id      = try(templatestring(local.management_group_configuration.decommissioned.id, local.management_group_format_variables), "")
  sandbox_management_group_id             = try(templatestring(local.management_group_configuration.sandbox.id, local.management_group_format_variables), "")
  management_management_group_id          = try(templatestring(local.management_group_configuration.management.id, local.management_group_format_variables), "")
  connectivity_management_group_id        = try(templatestring(local.management_group_configuration.connectivity.id, local.management_group_format_variables), "")
  identity_management_group_id            = try(templatestring(local.management_group_configuration.identity.id, local.management_group_format_variables), "")
  corp_management_group_id                = try(templatestring(local.management_group_configuration.corp.id, local.management_group_format_variables), "")
  online_management_group_id              = try(templatestring(local.management_group_configuration.online.id, local.management_group_format_variables), "")
  confidential_corp_management_group_id   = try(templatestring(local.management_group_configuration.confidential_corp.id, local.management_group_format_variables), "")
  confidential_online_management_group_id = try(templatestring(local.management_group_configuration.confidential_online.id, local.management_group_format_variables), "")

  root_display_name                = try(local.management_group_configuration.root.display_name, "")
  platform_display_name            = try(local.management_group_configuration.platform.display_name, "")
  landing_zone_display_name        = try(local.management_group_configuration.landingzones.display_name, "")
  decommissioned_display_name      = try(local.management_group_configuration.decommissioned.display_name, "")
  sandbox_display_name             = try(local.management_group_configuration.sandbox.display_name, "")
  management_display_name          = try(local.management_group_configuration.management.display_name, "")
  connectivity_display_name        = try(local.management_group_configuration.connectivity.display_name, "")
  identity_display_name            = try(local.management_group_configuration.identity.display_name, "")
  corp_display_name                = try(local.management_group_configuration.corp.display_name, "")
  online_display_name              = try(local.management_group_configuration.online.display_name, "")
  confidential_corp_display_name   = try(local.management_group_configuration.confidential_corp.display_name, "")
  confidential_online_display_name = try(local.management_group_configuration.confidential_online.display_name, "")

  alz_management_groups = [
    {
      archetypes   = jsonencode(local.root_archtypes)
      display_name = local.root_display_name
      exists       = false
      id           = local.root_management_group_id
      parent_id    = jsonencode(null)
    },
    {
      archetypes   = jsonencode(local.platform_archtypes)
      display_name = local.platform_display_name
      exists       = false
      id           = local.platform_management_group_id
      parent_id    = jsonencode(local.root_management_group_id)
    },
    {
      archetypes   = jsonencode(local.landingzones_archtypes)
      display_name = local.landing_zone_display_name
      exists       = false
      id           = local.landing_zone_management_group_id
      parent_id    = jsonencode(local.root_management_group_id)
    },
    {
      archetypes   = jsonencode(local.sandbox_archtypes)
      display_name = local.sandbox_display_name
      exists       = false
      id           = local.sandbox_management_group_id
      parent_id    = jsonencode(local.root_management_group_id)
    },
    {
      archetypes   = jsonencode(local.decommissioned_archtypes)
      display_name = local.decommissioned_display_name
      exists       = false
      id           = local.decommissioned_management_group_id
      parent_id    = jsonencode(local.root_management_group_id)
    },
    {
      archetypes   = jsonencode(local.management_archtypes)
      display_name = local.management_display_name
      exists       = false
      id           = local.management_management_group_id
      parent_id    = jsonencode(local.platform_management_group_id)
    },
    {
      archetypes   = jsonencode(local.connectivity_archtypes)
      display_name = local.connectivity_display_name
      exists       = false
      id           = local.connectivity_management_group_id
      parent_id    = jsonencode(local.platform_management_group_id)
    },
    {
      archetypes   = jsonencode(local.identity_archtypes)
      display_name = local.identity_display_name
      exists       = false
      id           = local.identity_management_group_id
      parent_id    = jsonencode(local.platform_management_group_id)
    },
    {
      archetypes   = jsonencode(local.corp_archtypes)
      display_name = local.corp_display_name
      exists       = false
      id           = local.corp_management_group_id
      parent_id    = jsonencode(local.landing_zone_management_group_id)
    },
    {
      archetypes   = jsonencode(local.online_archtypes)
      display_name = local.online_display_name
      exists       = false
      id           = local.online_management_group_id
      parent_id    = jsonencode(local.landing_zone_management_group_id)
    },
    {
      archetypes   = jsonencode(local.confidential_corp_archtypes)
      display_name = local.confidential_corp_display_name
      exists       = false
      id           = local.confidential_corp_management_group_id
      parent_id    = jsonencode(local.landing_zone_management_group_id)
    },
    {
      archetypes   = jsonencode(local.confidential_online_archtypes)
      display_name = local.confidential_online_display_name
      exists       = false
      id           = local.confidential_online_management_group_id
      parent_id    = jsonencode(local.landing_zone_management_group_id)
    }
  ]

  platform_management_groups = [for k, v in local.platform_management_group_children :
    {
      archetypes   = jsonencode(try(v.archetypes, []))
      display_name = try(v.display_name, "")
      exists       = false
      id           = try(templatestring(v.id, local.management_group_format_variables), "")
      parent_id    = jsonencode(local.platform_management_group_id)
    }
  ]

  landing_zone_management_groups = [for k, v in local.landing_zone_management_group_children :
    {
      archetypes   = jsonencode(try(v.archetypes, []))
      display_name = try(v.display_name, "")
      exists       = false
      id           = try(templatestring(v.id, local.management_group_format_variables), "")
      parent_id    = jsonencode(local.landing_zone_management_group_id)
    }
  ]

  management_groups = concat(local.alz_management_groups, local.platform_management_groups, local.landing_zone_management_groups)

  template_vars = {
    architecture_definition_name = var.architecture_definition_name
    management_groups            = local.management_groups
  }

  template_file = templatefile(local.template_file_path, local.template_vars)

  # Validate management group configuration
  management_groups_validation_map = {
    root = {
      id           = local.root_management_group_id
      display_name = local.root_display_name
    }
    platform = {
      id           = local.platform_management_group_id,
      display_name = local.platform_display_name
    }
    landing_zone = {
      id           = local.landing_zone_management_group_id
      display_name = local.landing_zone_display_name
    }
    decommissioned = {
      id           = local.decommissioned_management_group_id
      display_name = local.decommissioned_display_name
    }
    sandbox = {
      id           = local.sandbox_management_group_id
      display_name = local.sandbox_display_name
    }
    management = {
      id           = local.management_management_group_id
      display_name = local.management_display_name
    }
    connectivity = {
      id           = local.connectivity_management_group_id
      display_name = local.connectivity_display_name
    }
    identity = {
      id           = local.identity_management_group_id
      display_name = local.identity_display_name
    }
    corp = {
      id           = local.corp_management_group_id
      display_name = local.corp_display_name
    }
    online = {
      id           = local.online_management_group_id
      display_name = local.online_display_name
    }
    confidential_corp = {
      id           = local.confidential_corp_management_group_id
      display_name = local.confidential_corp_display_name
    }
    confidential_online = {
      id           = local.confidential_online_management_group_id
      display_name = local.confidential_online_display_name
    }
  }
  management_groups_validation = [for k, v in local.management_groups_validation_map : k if v.id == "" || v.display_name == ""]
}
