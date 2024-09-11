output "architecture_definition_json" {
  value = local.has_custom_architecture_definition ? data.local_file.custom_architecture_definition_json[0].content : local.template_file
}
