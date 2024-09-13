output "architecture_definition_json" {
  value = local.has_architecture_definition_override ? data.local_file.architecture_definition_override_json[0].content : local.template_file
}
