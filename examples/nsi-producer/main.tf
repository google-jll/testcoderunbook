provider "google" {
  project = var.project_id
  region  = var.region
}

# Management VPC + subnets (in-repo module).
module "mgmt_vpc" {
  source = "../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "nsi-producer-mgmt"
  region           = var.region
  environment      = "mgmt"
  subnet_cidr_dmz  = "10.0.0.0/28"
  subnet_cidr_app  = "10.0.0.16/28"
  subnet_cidr_data = "10.0.0.32/28"
}

# Dataplane VPC + subnets (in-repo module).
module "data_vpc" {
  source = "../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "nsi-producer-data"
  region           = var.region
  environment      = "data"
  subnet_cidr_dmz  = "10.0.1.0/28"
  subnet_cidr_app  = "10.0.1.16/28"
  subnet_cidr_data = "10.0.1.32/28"
}

# Cloud NAT so the firewall management interface can reach the internet for
# licensing/bootstrap (in-repo module; creates its own Cloud Router).
module "mgmt_nat" {
  source = "../../modules/cloud-nat"

  project_id    = var.project_id
  region        = var.region
  network       = module.mgmt_vpc.vpc_id
  create_router = true
  router        = "nsi-producer-mgmt-router"
  name          = "nsi-producer-mgmt-nat"
}

# NSI producer: VM-Series firewall MIG, internal load balancer, and the
# intercept/mirroring deployment group.
module "nsi_producer" {
  source = "../../modules/nsi-producer"

  project_id = var.project_id
  region     = var.region

  data_network_id    = module.data_vpc.vpc_id
  data_subnetwork_id = module.data_vpc.subnet_data_id
  mgmt_subnetwork_id = module.mgmt_vpc.subnet_dmz_id

  mirroring_deployment = var.mirroring_deployment

  # Plain VPC firewall rules, created by the producer. Keyed by name; each targets
  # a network (here the mgmt + data VPCs created above).
  firewall_rules = {
    mgmt = {
      network_name  = module.mgmt_vpc.vpc_name
      ingress_rules = [{ name = "mgmt", priority = 1000, source_ranges = ["0.0.0.0/0"], allow = [{ protocol = "tcp", ports = ["443", "22", "3978"] }] }]
    }
    data = {
      network_name  = module.data_vpc.vpc_name
      ingress_rules = [{ name = "data", priority = 1000, source_ranges = ["0.0.0.0/0"], allow = [{ protocol = "all" }] }]
    }
  }

  # BYOL / registration (leave empty to plan; set for a real firewall deploy).
  csp_pin_id    = var.csp_pin_id
  csp_pin_value = var.csp_pin_value
  csp_authcodes = var.csp_authcodes
}
