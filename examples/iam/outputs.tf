output "project_roles" {
  description = "Roles applied at the project level."
  value       = module.projects_iam.roles
}

output "folder_roles" {
  description = "Roles applied at the folder level."
  value       = module.folders_iam.roles
}
