output "architecture_definition_json" {
  value = local.has_custom_architecture_definition ? data.local_file.custom_architecture_definition_json[0].content : data.template_file.populated_architecture_definition_json.rendered
}
