output "firewall_policy_id" {
  description = "Id of the consumer network firewall policy."
  value       = module.firewall_policy.id
}

output "security_profile_group_id" {
  description = "Id of the custom security profile group applied by the firewall rules."
  value       = google_network_security_security_profile_group.main.id
}

output "intercept_endpoint_group_id" {
  description = "Id of the intercept endpoint group (null when mirroring_deployment = true)."
  value       = try(google_network_security_intercept_endpoint_group.main[0].id, null)
}

output "mirroring_endpoint_group_id" {
  description = "Id of the mirroring endpoint group (null when mirroring_deployment = false)."
  value       = try(google_network_security_mirroring_endpoint_group.main[0].id, null)
}
