output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "The URI of the created Standalone VPC."
}

output "vpc_self_link" {
  value       = google_compute_network.vpc.self_link
  description = "The self-link of the VPC, used for hub attachments."
}

output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "The name of the VPC."
}

output "subnet_dmz_name" {
  value       = google_compute_subnetwork.dmz_tier.name
  description = "The name of the DMZ subnet."
}

output "subnet_dmz_id" {
  value       = google_compute_subnetwork.dmz_tier.id
  description = "The ID of the DMZ subnet."
}

output "subnet_app_name" {
  value       = google_compute_subnetwork.app_tier.name
  description = "The name of the App subnet."
}

output "subnet_app_id" {
  value       = google_compute_subnetwork.app_tier.id
  description = "The ID of the App subnet."
}

output "subnet_data_name" {
  value       = google_compute_subnetwork.data_tier.name
  description = "The name of the Data subnet."
}

output "subnet_data_id" {
  value       = google_compute_subnetwork.data_tier.id
  description = "The ID of the Data subnet."
}