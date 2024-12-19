data "local_file" "architecture_definition_override_json" {
  count    = local.has_architecture_definition_override ? 1 : 0
  filename = var.architecture_definition_override_path
}
