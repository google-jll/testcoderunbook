provider "google" {
  project = var.project_id
  region  = var.region
}

# -------------------------------------------------------------------------------------
# 1. Look up the existing VPC networks the DNS config binds to (must already exist).
#    - platform VPC: the dedicated AD / hub VPC that hosts the inbound endpoint.
#    - app spoke VPCs: workload VPCs the private/forwarding zones are authorized on.
# -------------------------------------------------------------------------------------
data "google_compute_network" "platform_vpc" {
  name    = var.platform_vpc_name
  project = var.project_id
}

data "google_compute_network" "app_spoke_vpc" {
  for_each = toset(var.app_spoke_vpc_names)
  name     = each.value
  project  = var.project_id
}

# -------------------------------------------------------------------------------------
# 2. Cloud DNS hybrid infrastructure (inbound endpoint, PSC/PGA zones, private &
#    forwarding zones) — everything driven by variables.
# -------------------------------------------------------------------------------------
module "gcp_dns_infrastructure" {
  source = "../../modules/custom-dns"

  project_id        = var.project_id
  platform_vpc_id   = data.google_compute_network.platform_vpc.id
  app_spoke_vpc_ids = [for net in data.google_compute_network.app_spoke_vpc : net.id]

  # Inbound endpoint policy on the platform VPC (for AD conditional forwarders).
  enable_inbound_endpoint = var.enable_inbound_endpoint
  inbound_policy_name     = var.inbound_policy_name

  # googleapis.com / p.googleapis.com private zones pointing at the PGA/PSC VIPs.
  enable_google_apis_psc_dns = var.enable_google_apis_psc_dns
  google_apis_vips           = var.google_apis_vips

  # Custom private zones and outbound forwarding zones.
  private_zones    = var.private_zones
  forwarding_zones = var.forwarding_zones
}
