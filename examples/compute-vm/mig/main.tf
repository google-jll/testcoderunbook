provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Self-contained network for the example.
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "mig-flex-example-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "mig-flex-example-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/24"
}

module "instance_template" {
  source = "../../../modules/compute-vm/instance_template"

  project_id         = var.project_id
  region             = var.region
  subnetwork         = google_compute_subnetwork.subnet.self_link
  subnetwork_project = var.project_id
  name_prefix        = "mig-flex"
}

# Flexible (regional) MIG: distribution_policy_target_shape = "ANY" lets Compute
# Engine place instances in whichever zones of the region have capacity.
module "mig" {
  source = "../../../modules/compute-vm/mig"

  project_id        = var.project_id
  region            = var.region
  hostname          = "mig-flex"
  instance_template = module.instance_template.self_link
  target_size       = var.target_size

  distribution_policy_target_shape = "ANY"
}
