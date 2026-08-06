output "project_id" {
  description = "The GCP project you want to enable APIs on"
  value       = element(concat([for v in google_project_service.project_services : v.project], [var.project_id]), 0)
}

output "enabled_apis" {
  description = "Enabled APIs in the project"
  value       = [for api in google_project_service.project_services : api.service]
}

output "enabled_api_identities" {
  description = "Enabled API identities in the project"
  value       = { for i in google_project_service_identity.project_service_identities : i.service => i.email }
}
