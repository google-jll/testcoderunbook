output "spoke_vpc_id" {
  description = "The URI of the created spoke VPC network."
  value       = module.spoke_vpc.vpc_id
}

output "spoke_vpc_name" {
  description = "The name of the created spoke VPC network."
  value       = module.spoke_vpc.vpc_name
}

output "ncc_hub_id" {
  description = "The target NCC Mesh Hub ID that this spoke is attached to."
  value       = module.ncc_spoke.ncc_hub_id
}

output "vpc_spokes" {
  description = "Created VPC spoke objects."
  value       = module.ncc_spoke.vpc_spokes
}

output "spokes" {
  description = "All created spoke objects prefixed with spoke type."
  value       = module.ncc_spoke.spokes
}
