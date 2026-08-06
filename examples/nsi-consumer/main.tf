provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Consumer VPC + subnets (in-repo module). This is the network whose traffic is
# steered to the producer's firewalls for inspection.
module "consumer_vpc" {
  source = "../../modules/network-foundation"

  project_id       = var.project_id
  vpc_name         = "nsi-consumer"
  region           = var.region
  environment      = "consumer"
  subnet_cidr_dmz  = "10.1.0.0/28"
  subnet_cidr_app  = "10.1.0.16/28"
  subnet_cidr_data = "10.1.0.32/28"
}

# NSI consumer: endpoint group, security profile/group, and the firewall policy
# that intercepts/mirrors this VPC's traffic to the producer.
module "nsi_consumer" {
  source = "../../modules/nsi-consumer"

  project_id = var.project_id
  org_id     = var.org_id
  network_id = module.consumer_vpc.vpc_id

  # producer_dg comes from the producer's `deployment_group_id` output.
  producer_dg          = var.producer_dg
  mirroring_deployment = var.mirroring_deployment
}
