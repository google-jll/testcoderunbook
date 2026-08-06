output "instance_names" {
  description = "Names of the managed instances created from the template."
  value       = module.compute_instance.instances_details[*].name
}

output "instance_self_links" {
  description = "Self links of the managed instances."
  value       = module.compute_instance.instances_self_links
}

output "multi_nic_instance" {
  description = "Self link of the standalone multi-NIC / next-hop instance."
  value       = google_compute_instance.multi_nic.self_link
}

output "snapshot_policy" {
  description = "Name of the snapshot schedule resource policy."
  value       = module.disk_snapshots.policy.name
}
