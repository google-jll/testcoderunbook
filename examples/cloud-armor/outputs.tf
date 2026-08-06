output "security_policy_id" {
  description = "The ID of the provisioned Cloud Armor policy."
  value       = module.cloud_armor_whitelist.policy_id
}

output "security_policy_link" {
  description = "The self-link of the provisioned Cloud Armor policy."
  value       = module.cloud_armor_whitelist.policy_self_link
}

output "policy_name" {
  description = "The name of the provisioned Cloud Armor policy."
  value       = module.cloud_armor_whitelist.policy_name
}