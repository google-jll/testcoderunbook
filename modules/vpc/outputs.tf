output "network_id" {
  description = "The network id (projects/<project>/global/networks/<name>)."
  value       = google_compute_network.this.id
}

output "network_self_link" {
  description = "The network self link."
  value       = google_compute_network.this.self_link
}

output "network_name" {
  description = "The network name."
  value       = google_compute_network.this.name
}

output "subnets" {
  description = "Map of subnet name to its id/self_link/region/cidr."
  value = {
    for k, v in google_compute_subnetwork.this : k => {
      id            = v.id
      self_link     = v.self_link
      region        = v.region
      ip_cidr_range = v.ip_cidr_range
    }
  }
}
