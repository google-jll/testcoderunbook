output "deployed_vpc_self_link" {
  value       = module.network_foundation.vpc_self_link
  description = "The self-link of the deployed Standalone VPC."
}

output "deployed_subnet_dmz_id" {
  value       = module.network_foundation.subnet_dmz_id
  description = "The ID of the deployed DMZ subnet."
}

output "deployed_subnet_app_id" {
  value       = module.network_foundation.subnet_app_id
  description = "The ID of the deployed App subnet."
}

output "deployed_subnet_data_id" {
  value       = module.network_foundation.subnet_data_id
  description = "The ID of the deployed Data subnet."
}