provider "google" {
  project = var.spoke_project_id
  region  = var.region
}

# ------------------------------------------------------------------------------
# 1. Workload VPC (Spoke Network)
#    Created in the spoke/workload project using foundation modules.
# ------------------------------------------------------------------------------
module "spoke_vpc" {
  source = "../../../modules/network-foundation"

  project_id       = var.spoke_project_id
  vpc_name         = var.spoke_vpc_name
  region           = var.region
  environment      = var.environment
  subnet_cidr_dmz  = var.subnet_cidr_dmz
  subnet_cidr_app  = var.subnet_cidr_app
  subnet_cidr_data = var.subnet_cidr_data
}

# ------------------------------------------------------------------------------
# 2. Attach Spoke to Existing NCC Mesh Hub
#    Uses `modules/ncc-mesh` with `create_hub = false` so only the spoke
#    resource is managed without recreating or managing the NCC Hub.
# ------------------------------------------------------------------------------
module "ncc_spoke" {
  source = "../../../modules/ncc-mesh"

  project_id      = var.spoke_project_id
  create_hub      = false
  ncc_hub_id      = var.ncc_hub_id
  ncc_hub_name    = var.ncc_hub_name
  ncc_hub_project = var.hub_project_id

  vpc_spokes = {
    (var.spoke_name) = {
      uri         = module.spoke_vpc.vpc_id
      description = "Workload VPC spoke attached to pre-existing NCC Mesh Hub"
      labels = {
        environment = var.environment
        managed_by  = "terraform"
      }
    }
  }
}
