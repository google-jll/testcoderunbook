output "backend_service" {
  description = "Id of the regional backend service fronting the firewalls."
  value       = google_compute_region_backend_service.main.id
}

output "instance_group_manager" {
  description = "Id of the firewall regional managed instance group."
  value       = google_compute_region_instance_group_manager.main.id
}

output "service_account_email" {
  description = "Email of the firewall service account."
  value       = google_service_account.main.email
}

output "forwarding_rules" {
  description = "Map of zone => forwarding rule id."
  value       = { for k, v in google_compute_forwarding_rule.main : k => v.id }
}

output "intercept_deployment_group_id" {
  description = "Id of the intercept deployment group (null when mirroring_deployment = true)."
  value       = try(google_network_security_intercept_deployment_group.main[0].id, null)
}

output "mirroring_deployment_group_id" {
  description = "Id of the mirroring deployment group (null when mirroring_deployment = false)."
  value       = try(google_network_security_mirroring_deployment_group.main[0].id, null)
}

output "firewall_rules" {
  description = "Map of firewall_rules key to the created firewall module (ingress/egress rule objects)."
  value       = { for k, v in module.firewall : k => v.firewall_rules_ingress_egress }
}
