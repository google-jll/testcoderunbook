output "secrets" {
  description = "Map of all created Secret Manager secret resource objects."
  value       = google_secret_manager_secret.secrets
}

output "secret_ids" {
  description = "Map of secret names to their fully-qualified resource IDs."
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.id }
}

output "secret_names" {
  description = "List of secret short names managed by this module."
  value       = keys(google_secret_manager_secret.secrets)
}

output "secret_versions" {
  description = "Map of all created secret version resource objects."
  value       = google_secret_manager_secret_version.versions
  sensitive   = true
}

output "secret_version_ids" {
  description = "Map of secret names to their created secret version resource IDs."
  value       = { for k, v in google_secret_manager_secret_version.versions : k => v.id }
}

output "secret_version_names" {
  description = "Map of secret names to their created secret version name/version number."
  value       = { for k, v in google_secret_manager_secret_version.versions : k => v.name }
}

output "id" {
  description = "The fully-qualified identifier of the primary secret (for single-secret module usage)."
  value       = length(keys(google_secret_manager_secret.secrets)) > 0 ? values(google_secret_manager_secret.secrets)[0].id : null
}

output "name" {
  description = "The short name of the primary secret (for single-secret module usage)."
  value       = length(keys(google_secret_manager_secret.secrets)) > 0 ? values(google_secret_manager_secret.secrets)[0].secret_id : null
}

output "version_id" {
  description = "The fully-qualified identifier of the primary secret version (for single-secret module usage)."
  value       = length(keys(google_secret_manager_secret_version.versions)) > 0 ? values(google_secret_manager_secret_version.versions)[0].id : null
}
