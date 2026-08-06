output "inbound_policy_id" {
  description = "The ID of the inbound DNS policy."
  value       = try(google_dns_policy.inbound_policy[0].id, null)
}

output "inbound_endpoint_entry_guidance" {
  description = "Guidance on how to find the created Inbound Endpoint IPs for Active Directory configuration."
  value       = "Inbound DNS IPs are automatically allocated by GCP in each subnet of the Platform VPC. Use 'gcloud compute addresses list --filter=\"purpose=DNS_RESOLVER\"' or check Cloud DNS Inbound Policy in the GCP Console."
}

output "private_zone_names" {
  description = "Map of created private DNS zone names."
  value       = { for k, v in google_dns_managed_zone.private_zone : k => v.name }
}

output "forwarding_zone_names" {
  description = "Map of created forwarding DNS zone names."
  value       = { for k, v in google_dns_managed_zone.forwarding_zone : k => v.name }
}
