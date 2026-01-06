# When creating a new project, Azure DevOps automatically creates a default repository
# with the same name as the project. We need to rename this default repo to avoid conflicts
# with our Terraform-managed repository.
resource "azuredevops_git_repository" "default_rename" {
  count          = var.create_project ? 1 : 0
  project_id     = azuredevops_project.alz[0].id
  name           = "${var.project_name}-default"
  default_branch = "refs/heads/main"

  initialization {
    init_type = "Clean"
  }

  lifecycle {
    ignore_changes = [initialization, default_branch]
  }

  depends_on = [azuredevops_project.alz]
}

resource "azuredevops_git_repository" "alz" {
  depends_on     = [azuredevops_environment.alz, azuredevops_git_repository.default_rename]
  project_id     = local.project_id
  name           = var.repository_name
  default_branch = local.default_branch

  initialization {
    init_type = "Clean"
  }

  lifecycle {
    ignore_changes = [initialization]
  }
}

resource "azuredevops_git_repository_file" "alz" {
  for_each            = var.repository_files
  repository_id       = azuredevops_git_repository.alz.id
  file                = each.key
  content             = each.value.content
  branch              = local.default_branch
  commit_message      = "[skip ci]"
  overwrite_on_create = true
}

resource "azuredevops_branch_policy_min_reviewers" "alz" {
  depends_on = [azuredevops_git_repository_file.alz]
  project_id = local.project_id

  enabled  = length(var.approvers) > 1 && var.create_branch_policies
  blocking = true

  settings {
    reviewer_count                         = 1
    submitter_can_vote                     = false
    last_pusher_cannot_approve             = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true

    scope {
      repository_id  = azuredevops_git_repository.alz.id
      repository_ref = azuredevops_git_repository.alz.default_branch
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "alz" {
  depends_on = [azuredevops_git_repository_file.alz]
  project_id = local.project_id

  enabled  = var.create_branch_policies
  blocking = true

  settings {
    allow_squash                  = true
    allow_rebase_and_fast_forward = false
    allow_basic_no_fast_forward   = false
    allow_rebase_with_merge       = false

    scope {
      repository_id  = azuredevops_git_repository.alz.id
      repository_ref = azuredevops_git_repository.alz.default_branch
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_build_validation" "alz" {
  depends_on = [azuredevops_git_repository_file.alz]
  project_id = local.project_id

  enabled  = var.create_branch_policies
  blocking = true

  settings {
    display_name        = "Terraform Validation"
    build_definition_id = azuredevops_build_definition.alz["ci"].id
    valid_duration      = 720

    scope {
      repository_id  = azuredevops_git_repository.alz.id
      repository_ref = azuredevops_git_repository.alz.default_branch
      match_type     = "Exact"
    }
  }
}
