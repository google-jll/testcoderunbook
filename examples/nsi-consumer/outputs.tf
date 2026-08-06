output "firewall_policy_id" {
  description = "Id of the consumer network firewall policy."
  value       = module.nsi_consumer.firewall_policy_id
}

output "security_profile_group_id" {
  description = "Id of the security profile group applied to the consumer VPC."
  value       = module.nsi_consumer.security_profile_group_id
}
