output "keyring" {
  description = "The created KeyRing resource object."
  value       = google_kms_key_ring.keyring
}

output "keyring_id" {
  description = "The fully-qualified identifier of the created KeyRing."
  value       = google_kms_key_ring.keyring.id
}

output "keyring_name" {
  description = "The name of the created KeyRing."
  value       = google_kms_key_ring.keyring.name
}

output "keyring_location" {
  description = "The location of the created KeyRing."
  value       = google_kms_key_ring.keyring.location
}

output "keys" {
  description = "Map of all created CryptoKey resource objects."
  value       = google_kms_crypto_key.keys
}

output "key_ids" {
  description = "Map of crypto key names to their fully-qualified resource IDs."
  value       = { for k, v in google_kms_crypto_key.keys : k => v.id }
}

output "key_names" {
  description = "List of crypto key names managed by this module."
  value       = keys(google_kms_crypto_key.keys)
}

output "primary_version_ids" {
  description = "Map of crypto key names to their primary version IDs (where available)."
  value = {
    for k, v in google_kms_crypto_key.keys : k => try(v.primary[0].name, null)
  }
}
