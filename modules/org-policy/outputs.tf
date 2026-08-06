output "boolean_policies" {
  description = "Map of created Boolean Organization Policy resources."
  value       = google_org_policy_policy.boolean_policies
}

output "list_policies" {
  description = "Map of created List Organization Policy resources."
  value       = google_org_policy_policy.list_policies
}

output "boolean_policy_ids" {
  description = "Map of constraint names to Boolean Policy resource IDs."
  value       = { for k, v in google_org_policy_policy.boolean_policies : k => v.id }
}

output "list_policy_ids" {
  description = "Map of constraint names to List Policy resource IDs."
  value       = { for k, v in google_org_policy_policy.list_policies : k => v.id }
}
