provider "google" {
  project = var.project_id
  region  = var.region
}

module "network_foundation" {
  source           = "../../modules/network-foundation"
  project_id       = var.project_id
  vpc_name         = var.vpc_name
  environment      = var.environment
  region           = var.region
  subnet_cidr_dmz  = var.subnet_cidr_dmz
  subnet_cidr_app  = var.subnet_cidr_app
  subnet_cidr_data = var.subnet_cidr_data

  # For security, default egress route to the internet is suppressed;
  # traffic must transit the Palo Alto transit hub for inspection.
  delete_default_internet_route = true
  enable_internet_egress_route  = false
}