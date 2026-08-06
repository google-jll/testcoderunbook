provider "google" {
  project = var.project_id
}

# Three spoke VPCs, built from the in-repo network-foundation module (no registry
# module pulls). Their network URIs are attached to the NCC mesh hub as spokes.
# In a mesh hub all three reach each other any-to-any.
module "spoke_a_vpc" {
  source = "../../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "ncc-mesh-spoke-a-vpc"
  region           = var.region
  environment      = "spoke-a"
  subnet_cidr_dmz  = "10.110.0.0/24"
  subnet_cidr_app  = "10.110.1.0/24"
  subnet_cidr_data = "10.110.2.0/24"
}

module "spoke_b_vpc" {
  source = "../../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "ncc-mesh-spoke-b-vpc"
  region           = var.region
  environment      = "spoke-b"
  subnet_cidr_dmz  = "10.111.0.0/24"
  subnet_cidr_app  = "10.111.1.0/24"
  subnet_cidr_data = "10.111.2.0/24"
}

module "spoke_c_vpc" {
  source = "../../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "ncc-mesh-spoke-c-vpc"
  region           = var.region
  environment      = "spoke-c"
  subnet_cidr_dmz  = "10.112.0.0/24"
  subnet_cidr_app  = "10.112.1.0/24"
  subnet_cidr_data = "10.112.2.0/24"
}

# MESH-topology hub. No center/edge groups — every spoke reaches every other
# spoke any-to-any through the implicit default group.
module "ncc" {
  source = "../../../modules/ncc-mesh"

  project_id          = var.project_id
  ncc_hub_name        = var.ncc_hub_name
  ncc_hub_description = "NCC mesh hub with any-to-any spokes"

  vpc_spokes = {
    "spoke-a" = { uri = module.spoke_a_vpc.vpc_id }
    "spoke-b" = { uri = module.spoke_b_vpc.vpc_id }
    "spoke-c" = { uri = module.spoke_c_vpc.vpc_id }
  }
}
