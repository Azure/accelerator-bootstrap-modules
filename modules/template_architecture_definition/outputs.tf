output "architecture_definition_json" {
  value = local.has_architecture_definition_override ? data.local_file.architecture_definition_override_json[0].content : local.template_file

  precondition {
    condition     = length(local.management_group_configuration) != 0
    error_message = "The management group configuration is required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.root, null) != null &&
      try(local.management_group_configuration.root.id, null) != null &&
      try(local.management_group_configuration.root.display_name, null) != null
    )
    error_message = "The root management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.platform, null) != null &&
      try(local.management_group_configuration.platform.id, null) != null &&
      try(local.management_group_configuration.platform.display_name, null) != null
    )
    error_message = "The platform management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.landingzones, null) != null &&
      try(local.management_group_configuration.landingzones.id, null) != null &&
      try(local.management_group_configuration.landingzones.display_name, null) != null
    )
    error_message = "The landing zones management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.decommissioned, null) != null &&
      try(local.management_group_configuration.decommissioned.id, null) != null &&
      try(local.management_group_configuration.decommissioned.display_name, null) != null
    )
    error_message = "The decommissioned management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.sandbox, null) != null &&
      try(local.management_group_configuration.sandbox.id, null) != null &&
      try(local.management_group_configuration.sandbox.display_name, null) != null
    )
    error_message = "The sandbox management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.management, null) != null &&
      try(local.management_group_configuration.management.id, null) != null &&
      try(local.management_group_configuration.management.display_name, null) != null
    )
    error_message = "The management management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.connectivity, null) != null &&
      try(local.management_group_configuration.connectivity.id, null) != null &&
      try(local.management_group_configuration.connectivity.display_name, null) != null
    )
    error_message = "The connectivity management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.identity, null) != null &&
      try(local.management_group_configuration.identity.id, null) != null &&
      try(local.management_group_configuration.identity.display_name, null) != null
    )
    error_message = "The identity management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.corp, null) != null &&
      try(local.management_group_configuration.corp.id, null) != null &&
      try(local.management_group_configuration.corp.display_name, null) != null
    )
    error_message = "The corp management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.online, null) != null &&
      try(local.management_group_configuration.online.id, null) != null &&
      try(local.management_group_configuration.online.display_name, null) != null
    )
    error_message = "The online management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.confidential_corp, null) != null &&
      try(local.management_group_configuration.confidential_corp.id, null) != null &&
      try(local.management_group_configuration.confidential_corp.display_name, null) != null
    )
    error_message = "The confidential corp management group, management group ID, and display name are required"
  }

  precondition {
    condition = (
      try(local.management_group_configuration.confidential_online, null) != null &&
      try(local.management_group_configuration.confidential_online.id, null) != null &&
      try(local.management_group_configuration.confidential_online.display_name, null) != null
    )
    error_message = "The confidential online management group, management group ID, and display name are required"
  }

  precondition {
    condition     = try([for k, v in local.platform_management_group_children : [v.id, v.display_name]], null) != null
    error_message = "The platform management group children management group ID and display name are required"
  }

  precondition {
    condition     = try([for k, v in local.landing_zone_management_group_children : [v.id, v.display_name]], null) != null
    error_message = "The landing zone management group children management group ID and display name are required"
  }
}
