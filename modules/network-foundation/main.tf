# 1. Standalone VPC Network
resource "google_compute_network" "vpc" {
  project                                   = var.project_id
  name                                      = var.vpc_name
  auto_create_subnetworks                   = false # Suppress auto-creation to enforce standalone design
  mtu                                       = 1460
  delete_default_routes_on_create           = var.delete_default_internet_route
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"
}

# 2. Three-Tier Subnets (GCP subnets span all regional availability zones natively)
resource "google_compute_subnetwork" "dmz_tier" {
  name                     = "sb-${var.region}-${var.environment}-dmz"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr_dmz
  private_ip_google_access = true # Enable Private Google Access (PGA)
}

resource "google_compute_subnetwork" "app_tier" {
  name                     = "sb-${var.region}-${var.environment}-app"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr_app
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "data_tier" {
  name                     = "sb-${var.region}-${var.environment}-data"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr_data
  private_ip_google_access = true # Supports Private Service Connect (PSC)
}

# 3. Native Routing (App teams cannot alter. Explicit defaults only.)
resource "google_compute_route" "default_internet_egress" {
  count            = var.enable_internet_egress_route ? 1 : 0
  name             = "rt-${var.vpc_name}-default-internet"
  project          = var.project_id
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}