resource "github_actions_runner_group" "alz" {
  count                   = local.use_runner_group ? 1 : 0
  name                    = var.runner_group_name
  visibility              = "selected"
  selected_repository_ids = var.use_template_repository ? [github_repository.alz.repo_id, github_repository.alz_templates[0].repo_id] : [github_repository.alz.repo_id]
}
