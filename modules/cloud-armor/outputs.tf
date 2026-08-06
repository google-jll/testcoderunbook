output "policy_id" {
  description = "The ID of the created Cloud Armor security policy."
  value       = google_compute_security_policy.policy.id
}

output "policy_self_link" {
  description = "The URI of the created Cloud Armor security policy."
  value       = google_compute_security_policy.policy.self_link
}

output "policy_name" {
  description = "Cloud Armor security policy name."
  value       = google_compute_security_policy.policy.name
}