output "architecture_definition_json" {
  value = local.has_architecture_definition_override ? data.local_file.architecture_definition_override_json[0].content : local.template_file

  precondition {
    condition     = length(local.management_group_configuration) != 0
    error_message = "The management group configuration is required"
  }

  precondition {
    condition     = length(local.management_groups_validation) == 0
    error_message = format("Management group ID and display name are required for %s management group(s).", join(", ", local.management_groups_validation))
  }

  precondition {
    condition     = try([for k, v in local.platform_management_group_children : [v.id, v.display_name]], null) != null
    error_message = "Management group ID and display name are required for platform management group children."
  }

  precondition {
    condition     = try([for k, v in local.landing_zone_management_group_children : [v.id, v.display_name]], null) != null
    error_message = "Management group ID and display name are required for landing zone management group children."
  }
}
