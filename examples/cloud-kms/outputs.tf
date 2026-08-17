output "keyring_id" {
  description = "The fully-qualified identifier of the provisioned KeyRing."
  value       = module.kms.keyring_id
}

output "keyring_name" {
  description = "The name of the provisioned KeyRing."
  value       = module.kms.keyring_name
}

output "key_ids" {
  description = "Map of crypto key names to their fully-qualified resource IDs."
  value       = module.kms.key_ids
}

output "key_names" {
  description = "List of crypto key names managed by the KMS module."
  value       = module.kms.key_names
}

output "app_service_account_email" {
  description = "Email of the application service account granted KMS access."
  value       = google_service_account.app_sa.email
}
