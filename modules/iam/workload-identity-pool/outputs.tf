output "pool_id" {
  description = "The Workload Identity Pool ID."
  value       = google_iam_workload_identity_pool.pool.workload_identity_pool_id
}

output "pool_name" {
  description = "The resource name of the Workload Identity Pool in the format 'projects/{project}/locations/global/workloadIdentityPools/{pool_id}'."
  value       = google_iam_workload_identity_pool.pool.name
}

output "pool_state" {
  description = "The state of the Workload Identity Pool."
  value       = google_iam_workload_identity_pool.pool.state
}

output "project_number" {
  description = "The numeric GCP project number."
  value       = data.google_project.project.number
}

output "provider_ids" {
  description = "Map of provider IDs created in the Workload Identity Pool."
  value       = { for k, v in google_iam_workload_identity_pool_provider.providers : k => v.workload_identity_pool_provider_id }
}

output "provider_names" {
  description = "Map of full resource names of the Workload Identity Pool Providers."
  value       = { for k, v in google_iam_workload_identity_pool_provider.providers : k => v.name }
}
