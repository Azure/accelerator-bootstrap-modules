locals {
  # Determine template architecture definition inputs from starter module tfvars
  starter_module_tfvars                 = jsondecode(file("${var.starter_module_folder_path}/terraform.tfvars.json"))
  default_prefix                        = local.starter_module_tfvars.default_prefix
  default_postfix                       = local.starter_module_tfvars.default_postfix
  enable_alz                            = local.starter_module_tfvars.apply_alz_archetypes_via_architecture_definition_template
  architecture_definition_override_path = local.starter_module_tfvars.architecture_definition_override_path
  default_template_file_path            = "${var.starter_module_folder_path}/templates/${var.architecture_definition_name}.alz_architecture_definition.json.tftpl"
  template_file_path                    = local.starter_module_tfvars.architecture_definition_template_path != "" ? local.starter_module_tfvars.architecture_definition_template_path : local.default_template_file_path

  # Customer has provided a custom architecture definition
  has_architecture_definition_override = local.architecture_definition_override_path != ""

  slz_architecture_definition_name = "slz"
  fsi_architecture_definition_name = "fsi"

  # SLZ archetypes
  slz_global = ["\"global\""]

  # FSI archetypes
  fsi_root = ["\"fsi_root\""]

  # SLZ/FSI confidential archetypes
  confidential = ["\"confidential\""]

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
  root = (local.enable_alz ?
    (var.architecture_definition_name == local.slz_architecture_definition_name ? concat(local.slz_global, local.alz_root) : concat(local.fsi_root, local.alz_root))
  : (var.architecture_definition_name == local.fsi_architecture_definition_name ? local.fsi_root : local.slz_global))
  platform            = local.enable_alz ? local.alz_platform : []
  landing_zone        = local.enable_alz ? local.alz_landing_zone : []
  decommissioned      = local.enable_alz ? local.alz_decommissioned : []
  sandboxes           = local.enable_alz ? local.alz_sandboxes : []
  corp                = local.enable_alz ? local.alz_corp : []
  online              = local.enable_alz ? local.alz_online : []
  management          = local.enable_alz ? local.alz_management : []
  connectivity        = local.enable_alz ? local.alz_connectivity : []
  identity            = local.enable_alz ? local.alz_identity : []
  confidential_corp   = local.confidential
  confidential_online = local.confidential

  template_vars = {
    architecture_definition_name            = var.architecture_definition_name
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

  template_file = templatefile(local.template_file_path, local.template_vars)
}
