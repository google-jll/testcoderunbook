output "pool_id" {
  description = "The Workload Identity Pool ID."
  value       = module.workload_identity_pool.pool_id
}

output "pool_name" {
  description = "The full resource name of the Workload Identity Pool."
  value       = module.workload_identity_pool.pool_name
}

output "provider_names" {
  description = "Map of full resource names of the Workload Identity Pool Providers."
  value       = module.workload_identity_pool.provider_names
}

output "service_account_email" {
  description = "The service account email configured for Workload Identity impersonation."
  value       = var.create_service_account ? module.service_account[0].email : var.service_account_id
}
