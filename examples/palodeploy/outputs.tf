output "panorama_instances_ips" {
  value       = data.google_compute_instance.panorama_instances[*].network_interface[0].network_ip
  description = "Private IPs of GCE instances created in Panorama Regional MIG"
}

output "panorama_mig_self_link" {
  value       = module.panorama_mig.self_link
  description = "Self-link of Panorama Regional Managed Instance Group"
}

output "panorama_instance_group" {
  value       = module.panorama_mig.instance_group
  description = "Instance group URL of Panorama Regional Managed Instance Group"
}

output "fw_mig_self_link" {
  value       = module.fw_mig.self_link
  description = "Self-link of VM-Series Firewall Regional Managed Instance Group"
}

output "fw_instance_group" {
  value       = module.fw_mig.instance_group
  description = "Instance group URL of VM-Series Firewall Regional Managed Instance Group"
}

output "mgmt_vpc_id" {
  value       = module.mgmt_vpc.network_id
  description = "Management VPC Network ID"
}

output "trust_vpc_id" {
  value       = module.trust_vpc.network_id
  description = "Trust VPC Network ID"
}

output "untrust_vpc_id" {
  value       = module.untrust_vpc.network_id
  description = "Untrust VPC Network ID"
}

output "mgmt_firewall_policy_id" {
  value       = module.mgmt_firewall_policy.id
  description = "Management Network Firewall Policy ID"
}
