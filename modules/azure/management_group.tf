resource "azapi_resource" "intermediate_root_management_group" {
  count     = var.intermediate_root_management_group_creation_enabled ? 1 : 0
  name      = var.intermediate_root_management_group_id
  parent_id = "/"
  type      = "Microsoft.Management/managementGroups@2023-04-01"
  body = {
    properties = {
      details = {
        parent = {
          id = "/providers/Microsoft.Management/managementGroups/${var.root_parent_management_group_id}"
        }
      }
      displayName = var.intermediate_root_management_group_display_name
    }
  }

  replace_triggers_external_values = [
    var.root_parent_management_group_id,
  ]
  response_export_values = []
  retry = {
    error_message_regex = [
      "AuthorizationFailed", # Avoids a eventual consistency issue where a recently created management group is not yet available for a GET operation.
      "Permission to Microsoft.Management/managementGroups on resources of type 'Write' is required on the management group or its ancestors."
    ]
  }

  timeouts {
    create = "60m"
    delete = "5m"
    read   = "60m"
    update = "5m"
  }
}
