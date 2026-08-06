provider "google" {
  project = var.project_id
}

# Two spoke VPCs, built from the in-repo network-foundation module (no registry
# module pulls). Their network URIs are attached to the NCC hub as spokes.
module "center_vpc" {
  source = "../../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "ncc-center-vpc"
  region           = var.region
  environment      = "hub"
  subnet_cidr_dmz  = "10.100.0.0/24"
  subnet_cidr_app  = "10.100.1.0/24"
  subnet_cidr_data = "10.100.2.0/24"
}

module "edge_vpc" {
  source = "../../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "ncc-edge-vpc"
  region           = var.region
  environment      = "edge"
  subnet_cidr_dmz  = "10.101.0.0/24"
  subnet_cidr_app  = "10.101.1.0/24"
  subnet_cidr_data = "10.101.2.0/24"
}

# STAR-topology hub with a "center" and an "edge" group. In a star hub, edge
# spokes exchange traffic only with center spokes, not with each other.
module "ncc" {
  source = "../../../modules/ncc-star"

  project_id              = var.project_id
  ncc_hub_name            = var.ncc_hub_name
  ncc_hub_description     = "NCC star hub with center and edge spokes"
  ncc_hub_policy_mode     = "PRESET"
  ncc_hub_preset_topology = "STAR"

  ncc_groups = {
    center = { name = "center" }
    edge   = { name = "edge" }
  }

  vpc_spokes = {
    "center-spoke" = {
      uri   = module.center_vpc.vpc_id
      group = "projects/${var.project_id}/locations/global/hubs/${var.ncc_hub_name}/groups/center"
    }
    "edge-spoke" = {
      uri   = module.edge_vpc.vpc_id
      group = "projects/${var.project_id}/locations/global/hubs/${var.ncc_hub_name}/groups/edge"
    }
  }
}
