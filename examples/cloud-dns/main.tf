/*
 * Combined Cloud DNS example. Creates one managed zone of each common type
 * (private, public, forwarding, peering) from the cloud-dns module, on a
 * self-contained pair of VPC networks.
 */

provider "google" {
  project = var.project_id
}

# Networks used by the private / forwarding / peering zones.
resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = "cloud-dns-example-network"
  auto_create_subnetworks = false
}

resource "google_compute_network" "peering_target" {
  project                 = var.project_id
  name                    = "cloud-dns-example-peering-target"
  auto_create_subnetworks = false
}

# Private zone with a couple of record sets.
module "private_zone" {
  source = "../../modules/cloud-dns"

  project_id = var.project_id
  type       = "private"
  name       = "example-private"
  domain     = "private.example.com."

  private_visibility_config_networks = [google_compute_network.main.self_link]

  recordsets = [
    { name = "app", type = "A", ttl = 300, records = ["10.0.0.10"] },
    { name = "db", type = "A", ttl = 300, records = ["10.0.0.20"] },
  ]
}

# Public zone with query logging enabled.
module "public_zone" {
  source = "../../modules/cloud-dns"

  project_id     = var.project_id
  type           = "public"
  name           = "example-public"
  domain         = "public.example.com."
  enable_logging = true

  recordsets = [
    { name = "www", type = "A", ttl = 300, records = ["203.0.113.10"] },
  ]
}

# Forwarding zone -> external resolvers.
module "forwarding_zone" {
  source = "../../modules/cloud-dns"

  project_id = var.project_id
  type       = "forwarding"
  name       = "example-forwarding"
  domain     = "forward.example.com."

  private_visibility_config_networks = [google_compute_network.main.self_link]
  target_name_server_addresses = [
    { ipv4_address = "8.8.8.8", forwarding_path = "default" },
    { ipv4_address = "8.8.4.4", forwarding_path = "default" },
  ]
}

# Peering zone -> another VPC network.
module "peering_zone" {
  source = "../../modules/cloud-dns"

  project_id = var.project_id
  type       = "peering"
  name       = "example-peering"
  domain     = "peer.example.com."

  private_visibility_config_networks = [google_compute_network.main.self_link]
  target_network                     = google_compute_network.peering_target.self_link
}
