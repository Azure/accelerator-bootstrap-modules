locals {
  organization_url = startswith(lower(var.organization_name), "https://") || startswith(lower(var.organization_name), "http://") ? var.organization_name : (var.use_legacy_organization_url ? "https://${var.organization_name}.visualstudio.com" : "https://dev.azure.com/${var.organization_name}")
}

locals {
  apply_key = "apply"
}

locals {
  authentication_scheme_workload_identity_federation = "WorkloadIdentityFederation"
}

locals {
  default_branch = "refs/heads/main"
}

locals {
  repository_name_templates = var.use_template_repository ? var.repository_name_templates : var.repository_name
}
