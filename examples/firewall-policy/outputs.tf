output "vpc_network_id" {
  description = "The ID of the created VPC network."
  value       = google_compute_network.vpc.id
}

output "vpc_network_name" {
  description = "The name of the created VPC network."
  value       = google_compute_network.vpc.name
}

output "subnetwork_id" {
  description = "The ID of the created subnetwork."
  value       = google_compute_subnetwork.subnet.id
}

output "firewall_policy_id" {
  description = "The ID of the created Network Firewall Policy."
  value       = module.firewall_policy.id
}

output "firewall_policy_name" {
  description = "The name of the created Network Firewall Policy."
  value       = module.firewall_policy.name
}

output "firewall_policy_association_id" {
  description = "The association ID of the firewall policy with the VPC."
  value       = module.firewall_policy.association_id
}

output "secure_tag_keys" {
  description = "Map of created Secure Tag Keys."
  value       = module.secure_tags.keys
}

output "secure_tag_values" {
  description = "Map of created Secure Tag Values."
  value       = module.secure_tags.values
}

output "secure_tag_values_by_key" {
  description = "Nested map of [key_name][value_name] to Tag Value IDs."
  value       = module.secure_tags.values_by_key
}

output "app1_vm_id" {
  description = "The ID of the App1 VM instance."
  value       = google_compute_instance.app1_vm.id
}

output "app2_vm_id" {
  description = "The ID of the App2 VM instance."
  value       = google_compute_instance.app2_vm.id
}

output "app1_tag_binding_id" {
  description = "The ID of the location tag binding attaching app1 tag to vm-app1."
  value       = try(google_tags_location_tag_binding.app1_binding[0].id, null)
}

output "app2_tag_binding_id" {
  description = "The ID of the location tag binding attaching app2 tag to vm-app2."
  value       = try(google_tags_location_tag_binding.app2_binding[0].id, null)
}
