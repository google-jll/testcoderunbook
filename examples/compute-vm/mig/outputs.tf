output "self_link" {
  description = "Self link of the flexible (regional) managed instance group."
  value       = module.mig.self_link
}

output "instance_group" {
  description = "The full URL of the instance group created by the MIG."
  value       = module.mig.instance_group
}

output "region" {
  description = "The region the MIG was created in."
  value       = var.region
}
