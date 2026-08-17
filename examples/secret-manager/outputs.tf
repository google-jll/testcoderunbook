output "secret_ids" {
  description = "Map of secret names to their fully-qualified resource IDs."
  value       = module.secrets.secret_ids
}

output "secret_names" {
  description = "List of secret short names created by the module."
  value       = module.secrets.secret_names
}

output "secret_version_ids" {
  description = "Map of secret names to their created secret version resource IDs."
  value       = module.secrets.secret_version_ids
}

output "kms_key_id" {
  description = "The KMS CryptoKey ID used for CMEK secret encryption."
  value       = module.kms.key_ids["secret-manager-cmek-key"]
}

output "consumer_service_account_email" {
  description = "Email of the application service account granted secret accessor permission."
  value       = google_service_account.app_sa.email
}
