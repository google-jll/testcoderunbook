output "instances_self_links" {
  description = "List of self-links for compute instances"
  value       = google_compute_instance_from_template.compute_instance[*].self_link
}

output "instances_details" {
  description = "List of all details for compute instances"
  sensitive   = true
  value       = google_compute_instance_from_template.compute_instance[*]
}

output "available_zones" {
  description = "List of available zones in region"
  value       = data.google_compute_zones.available.names
}

output "service_account_email" {
  description = "The service account email associated with the instances."
  value       = try(google_compute_instance_from_template.compute_instance[0].service_account[0].email, null)
}

output "instance_name" {
  description = "The name of the first compute instance."
  value       = try(google_compute_instance_from_template.compute_instance[0].name, "")
}
