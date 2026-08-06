output "inbound_policy_id" {
  description = "The ID of the inbound DNS policy (null if disabled)."
  value       = module.gcp_dns_infrastructure.inbound_policy_id
}

output "inbound_endpoint_guidance" {
  description = "How to find the allocated inbound endpoint IPs for AD conditional forwarders."
  value       = module.gcp_dns_infrastructure.inbound_endpoint_entry_guidance
}

output "private_zone_names" {
  description = "Map of created private DNS zone names (includes the googleapis PSC/PGA zones when enabled)."
  value       = module.gcp_dns_infrastructure.private_zone_names
}

output "forwarding_zone_names" {
  description = "Map of created forwarding DNS zone names."
  value       = module.gcp_dns_infrastructure.forwarding_zone_names
}
