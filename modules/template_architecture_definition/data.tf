data "template_file" "populated_architecture_definition_json" {
  template = file(local.template_file_path)
  vars     = local.template_vars
}

data "local_file" "custom_architecture_definition_json" {
  count    = local.has_custom_architecture_definition ? 1 : 0
  filename = var.architecture_definition_path
}
