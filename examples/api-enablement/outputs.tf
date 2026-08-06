output "project_id" {
  description = "The project the APIs were enabled on."
  value       = module.api_enablement.project_id
}

output "enabled_apis" {
  description = "The list of enabled APIs."
  value       = module.api_enablement.enabled_apis
}
