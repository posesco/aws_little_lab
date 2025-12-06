output "tags" {
  description = "Complete map of common tags"
  value       = local.all_tags
}

output "base_tags" {
  description = "Base mandatory tags only"
  value       = local.base_tags
}

output "project" {
  description = "Project name"
  value       = var.project
}

output "env" {
  description = "Environment"
  value       = var.env
}