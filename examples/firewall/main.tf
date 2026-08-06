provider "google" {
  project = var.project_id
}

# Self-contained network for the example.
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "firewall-example-network"
  auto_create_subnetworks = false
}

module "firewall_rules" {
  source = "../../modules/firewall"

  project_id   = var.project_id
  network_name = google_compute_network.vpc.name

  ingress_rules = [
    {
      name          = "allow-ssh-iap"
      description   = "Allow SSH from the IAP range."
      source_ranges = ["35.235.240.0/20"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    {
      name          = "allow-internal"
      description   = "Allow all internal traffic within the VPC."
      source_ranges = ["10.0.0.0/8"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
        }, {
        protocol = "udp"
        ports    = ["0-65535"]
        }, {
        protocol = "icmp"
      }]
    },
  ]
}
