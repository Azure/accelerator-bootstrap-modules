locals {
  # Determine template architecture definition inputs from starter module tfvars
  starter_module_tfvars           = jsondecode(file("${var.starter_module_folder_path}/terraform.tfvars.json"))
  default_prefix                  = local.starter_module_tfvars.default_prefix
  default_postfix                 = local.starter_module_tfvars.default_postfix
  top_level_management_group_name = local.starter_module_tfvars.top_level_management_group_name
  default_template_file_path      = "${path.module}/templates/${var.architecture_definition_name}.alz_architecture_definition.json.tftpl"
  template_file_path              = var.architecture_definition_template_path != "" ? var.architecture_definition_template_path : local.default_template_file_path

  # Customer has provided a custom architecture definition
  has_architecture_definition_override = var.architecture_definition_override_path != ""

  # ALZ archetypes
  alz_root           = ["\"root\""]
  alz_platform       = ["\"platform\""]
  alz_landing_zone   = ["\"landing_zones\""]
  alz_decommissioned = ["\"decommissioned\""]
  alz_sandboxes      = ["\"sandboxes\""]
  alz_corp           = ["\"corp\""]
  alz_online         = ["\"online\""]
  alz_management     = ["\"management\""]
  alz_connectivity   = ["\"connectivity\""]
  alz_identity       = ["\"identity\""]

  # management group layered archetypes
  root                = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_root : []
  platform            = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_platform : []
  landing_zone        = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_landing_zone : []
  decommissioned      = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_decommissioned : []
  sandboxes           = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_sandboxes : []
  corp                = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_corp : []
  online              = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_online : []
  management          = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_management : []
  connectivity        = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_connectivity : []
  identity            = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_identity : []
  confidential_corp   = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_corp : []
  confidential_online = var.apply_alz_archetypes_via_architecture_definition_template ? local.alz_online : []

  template_vars = {
    architecture_definition_name            = var.architecture_definition_name
    top_level_management_group_name         = local.top_level_management_group_name
    root_management_group_id                = "${local.default_prefix}${local.default_postfix}"
    platform_management_group_id            = "${local.default_prefix}-platform${local.default_postfix}"
    landing_zone_management_group_id        = "${local.default_prefix}-landingzones${local.default_postfix}"
    decommissioned_management_group_id      = "${local.default_prefix}-decommissioned${local.default_postfix}"
    sandbox_management_group_id             = "${local.default_prefix}-sandbox${local.default_postfix}"
    corp_management_group_id                = "${local.default_prefix}-landingzones-corp${local.default_postfix}"
    online_management_group_id              = "${local.default_prefix}-landingzones-online${local.default_postfix}"
    management_management_group_id          = "${local.default_prefix}-platform-management${local.default_postfix}"
    connectivity_management_group_id        = "${local.default_prefix}-platform-connectivity${local.default_postfix}"
    identity_management_group_id            = "${local.default_prefix}-platform-identity${local.default_postfix}"
    confidential_corp_management_group_id   = "${local.default_prefix}-landingzones-confidential-corp${local.default_postfix}"
    confidential_online_management_group_id = "${local.default_prefix}-landingzones-confidential-online${local.default_postfix}"

    root_archetypes                = join(", ", local.root)
    platform_archetypes            = join(", ", local.platform)
    landing_zone_archetypes        = join(", ", local.landing_zone)
    decommissioned_archetypes      = join(", ", local.decommissioned)
    sandboxes_archetypes           = join(", ", local.sandboxes)
    corp_archetypes                = join(", ", local.corp)
    online_archetypes              = join(", ", local.online)
    management_archetypes          = join(", ", local.management)
    connectivity_archetypes        = join(", ", local.connectivity)
    identity_archetypes            = join(", ", local.identity)
    confidential_corp_archetypes   = join(", ", local.confidential_corp)
    confidential_online_archetypes = join(", ", local.confidential_online)
  }

  unclean_templated_file_content = templatefile(local.template_file_path, local.template_vars)

  # Templated file contents could have malformed json due hard-coded archetypes in the template file. 
  # This fixes commas in the json at beginning and end of arrays, and two consecutive commas in the arrays.
  # Occurs when there are no archetypes in the array that is being used to replace the template variable.
  template_file = replace(replace(replace(local.unclean_templated_file_content, "/\\[\\s*,\\s*/", "["), "/,\\s*\\]/", "]"), "/\\,\\s*,/", ",")
}
