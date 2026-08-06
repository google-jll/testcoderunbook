output "boolean_policy_ids" {
  description = "Map of created Boolean policy IDs."
  value       = module.org_policy.boolean_policy_ids
}

output "list_policy_ids" {
  description = "Map of created List policy IDs."
  value       = module.org_policy.list_policy_ids
}
