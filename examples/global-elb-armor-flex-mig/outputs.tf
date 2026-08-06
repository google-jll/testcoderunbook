output "elb_external_ip" {
  description = "The external IPv4 address assigned to the Global External Load Balancer forwarding rule."
  value       = module.global_elb.external_ip
}

output "cloud_armor_policy_name" {
  description = "Name of the Cloud Armor security policy."
  value       = module.cloud_armor.policy_name
}

output "cloud_armor_policy_self_link" {
  description = "Self-link URI of the Cloud Armor security policy."
  value       = module.cloud_armor.policy_self_link
}

output "nsi_producer_dg" {
  description = "Palo Alto NSI Producer Deployment Group URI linked to NSI Consumer."
  value       = var.producer_dg
}

output "secure_tag_key_id" {
  description = "Tag Key ID created for GCE instance classification."
  value       = module.secure_tags.keys["${var.tag_key_name}"]
}

output "secure_tag_value_id" {
  description = "Tag Value ID attached to MIG GCE instances."
  value       = module.secure_tags.values["${var.tag_key_name}/${var.tag_value_name}"]
}

output "mig_instance_group" {
  description = "URI of the Managed Instance Group."
  value       = module.mig.instance_group
}

output "mig_self_link" {
  description = "Self-link of the Managed Instance Group Manager."
  value       = module.mig.self_link
}

output "vpc_network_name" {
  description = "Name of the created VPC network."
  value       = module.vpc.network_name
}

output "subnet_id" {
  description = "ID of the created subnetwork."
  value       = module.vpc.subnets["${var.subnet_name}"].id
}
