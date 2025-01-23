locals {
  # Determine template architecture definition inputs from starter module tfvars
  starter_module_tfvars                  = jsondecode(file("${var.starter_module_folder_path}/terraform.tfvars.json"))
  default_prefix                         = try(local.starter_module_tfvars.default_prefix, "alz")
  default_postfix                        = try(local.starter_module_tfvars.default_postfix, "")
  management_group_configuration         = local.starter_module_tfvars.management_group_configuration # this input is require, fail if incorrect configuration is provided
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
  alz_sandboxes_archtype      = ["sandboxes"]
  alz_management_archtype     = ["management"]
  alz_connectivity_archtype   = ["connectivity"]
  alz_identity_archtype       = ["identity"]
  alz_corp_archtype           = ["corp"]
  alz_online_archtype         = ["online"]

  # management group layered archetypes
  root_archtypes                = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_root_archtype, local.management_group_configuration.root.archetypes) : local.management_group_configuration.root.archetypes
  platform_archtypes            = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_platform_archtype, local.management_group_configuration.platform.archetypes) : local.management_group_configuration.platform.archetypes
  landingzones_archtypes        = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_landing_zone_archtype, local.management_group_configuration.landingzones.archetypes) : local.management_group_configuration.landingzones.archetypes
  decommissioned_archtypes      = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_decommissioned_archtype, local.management_group_configuration.decommissioned.archetypes) : local.management_group_configuration.decommissioned.archetypes
  sandbox_archtypes             = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_sandboxes_archtype, local.management_group_configuration.sandbox.archetypes) : local.management_group_configuration.sandbox.archetypes
  management_archtypes          = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_management_archtype, local.management_group_configuration.management.archetypes) : local.management_group_configuration.management.archetypes
  connectivity_archtypes        = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_connectivity_archtype, local.management_group_configuration.connectivity.archetypes) : local.management_group_configuration.connectivity.archetypes
  identity_archtypes            = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_identity_archtype, local.management_group_configuration.identity.archetypes) : local.management_group_configuration.identity.archetypes
  corp_archtypes                = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_corp_archtype, local.management_group_configuration.corp.archetypes) : local.management_group_configuration.corp.archetypes
  online_archtypes              = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_online_archtype, local.management_group_configuration.online.archetypes) : local.management_group_configuration.online.archetypes
  confidential_corp_archtypes   = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_corp_archtype, local.management_group_configuration.confidential_corp.archetypes) : local.management_group_configuration.confidential_corp.archetypes
  confidential_online_archtypes = var.apply_alz_archetypes_via_architecture_definition_template ? concat(local.alz_online_archtype, local.management_group_configuration.confidential_online.archetypes) : local.management_group_configuration.confidential_online.archetypes

  management_group_format_variables = {
    default_prefix  = local.default_prefix
    default_postfix = local.default_postfix
  }

  root_management_group_id                = templatestring(local.management_group_configuration.root.id, local.management_group_format_variables)
  platform_management_group_id            = templatestring(local.management_group_configuration.platform.id, local.management_group_format_variables)
  landing_zone_management_group_id        = templatestring(local.management_group_configuration.landingzones.id, local.management_group_format_variables)
  decommissioned_management_group_id      = templatestring(local.management_group_configuration.decommissioned.id, local.management_group_format_variables)
  sandbox_management_group_id             = templatestring(local.management_group_configuration.sandbox.id, local.management_group_format_variables)
  management_management_group_id          = templatestring(local.management_group_configuration.management.id, local.management_group_format_variables)
  connectivity_management_group_id        = templatestring(local.management_group_configuration.connectivity.id, local.management_group_format_variables)
  identity_management_group_id            = templatestring(local.management_group_configuration.identity.id, local.management_group_format_variables)
  corp_management_group_id                = templatestring(local.management_group_configuration.corp.id, local.management_group_format_variables)
  online_management_group_id              = templatestring(local.management_group_configuration.online.id, local.management_group_format_variables)
  confidential_corp_management_group_id   = templatestring(local.management_group_configuration.confidential_corp.id, local.management_group_format_variables)
  confidential_online_management_group_id = templatestring(local.management_group_configuration.confidential_online.id, local.management_group_format_variables)

  alz_management_groups = [
    {
      "archetypes" : jsonencode(local.root_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.root.display_name),
      "exists" : false,
      "id" : jsonencode(local.root_management_group_id),
      "parent_id" : jsonencode(null)
    },
    {
      "archetypes" : jsonencode(local.platform_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.platform.display_name),
      "exists" : false,
      "id" : jsonencode(local.platform_management_group_id),
      "parent_id" : jsonencode(local.root_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.landingzones_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.landingzones.display_name),
      "exists" : false,
      "id" : jsonencode(local.landing_zone_management_group_id),
      "parent_id" : jsonencode(local.root_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.sandbox_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.sandbox.display_name),
      "exists" : false,
      "id" : jsonencode(local.sandbox_management_group_id),
      "parent_id" : jsonencode(local.root_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.decommissioned_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.decommissioned.display_name),
      "exists" : false,
      "id" : jsonencode(local.decommissioned_management_group_id),
      "parent_id" : jsonencode(local.root_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.management_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.management.display_name),
      "exists" : false,
      "id" : jsonencode(local.management_management_group_id),
      "parent_id" : jsonencode(local.platform_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.connectivity_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.connectivity.display_name),
      "exists" : false,
      "id" : jsonencode(local.connectivity_management_group_id),
      "parent_id" : jsonencode(local.platform_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.identity_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.identity.display_name),
      "exists" : false,
      "id" : jsonencode(local.identity_management_group_id),
      "parent_id" : jsonencode(local.platform_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.corp_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.corp.display_name),
      "exists" : false,
      "id" : jsonencode(local.corp_management_group_id),
      "parent_id" : jsonencode(local.landing_zone_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.online_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.online.display_name),
      "exists" : false,
      "id" : jsonencode(local.online_management_group_id),
      "parent_id" : jsonencode(local.landing_zone_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.confidential_corp_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.confidential_corp.display_name),
      "exists" : false,
      "id" : jsonencode(local.confidential_corp_management_group_id),
      "parent_id" : jsonencode(local.landing_zone_management_group_id)
    },
    {
      "archetypes" : jsonencode(local.confidential_online_archtypes),
      "display_name" : jsonencode(local.management_group_configuration.confidential_online.display_name),
      "exists" : false,
      "id" : jsonencode(local.confidential_online_management_group_id),
      "parent_id" : jsonencode(local.landing_zone_management_group_id)
    }
  ]

  platform_management_groups = [for k, v in local.platform_management_group_children :
    {
      "archetypes" : jsonencode(v.archetypes),
      "display_name" : jsonencode(v.display_name),
      "exists" : false,
      "id" : jsonencode(templatestring(v.id, local.management_group_format_variables)),
      "parent_id" : jsonencode(local.platform_management_group_id)
    }
  ]

  landing_zone_management_groups = [for k, v in local.landing_zone_management_group_children :
    {
      "archetypes" : jsonencode(v.archetypes),
      "display_name" : jsonencode(v.display_name),
      "exists" : false,
      "id" : jsonencode(templatestring(v.id, local.management_group_format_variables)),
      "parent_id" : jsonencode(local.landing_zone_management_group_id)
    }
  ]

  management_groups = concat(local.alz_management_groups, local.platform_management_groups, local.landing_zone_management_groups)

  template_vars = {
    architecture_definition_name = var.architecture_definition_name
    management_groups            = local.management_groups
  }

  template_file = templatefile(local.template_file_path, local.template_vars)
}
