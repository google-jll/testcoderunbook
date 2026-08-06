output "id" {
  description = "The ID of the network firewall policy."
  value       = google_compute_network_firewall_policy.main.id
}

output "name" {
  description = "The name of the network firewall policy."
  value       = google_compute_network_firewall_policy.main.name
}

output "network_firewall_policy_id" {
  description = "The unique identifier of the network firewall policy."
  value       = google_compute_network_firewall_policy.main.network_firewall_policy_id
}

output "rule_tuple_count" {
  description = "Total count of all firewall policy rule tuples."
  value       = google_compute_network_firewall_policy.main.rule_tuple_count
}

output "association_id" {
  description = "The ID of the network firewall policy association (if associated)."
  value       = try(google_compute_network_firewall_policy_association.main[0].id, null)
}

output "rules" {
  description = "Map of created custom firewall policy rules."
  value       = google_compute_network_firewall_policy_rule.custom_rules
}
