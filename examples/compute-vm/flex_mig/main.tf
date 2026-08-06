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
  name                    = "flex-mig-example-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "flex-mig-example-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.20.0.0/24"
}

# Base instance config. The template's machine_type is the fallback shape; each
# instance_selection below overrides it with its own machine_types.
module "instance_template" {
  source = "../../../modules/compute-vm/instance_template"

  project_id         = var.project_id
  region             = var.region
  subnetwork         = google_compute_subnetwork.subnet.self_link
  subnetwork_project = var.project_id
  name_prefix        = "flex-mig"
  machine_type       = "n2-standard-2"
}

# Flexible MIG: instance_selections makes the group create VMs from ANY of the
# listed machine types, preferring the lowest rank and falling back to the next
# when a shape is short on capacity. This is the "flex" instance_flexibility_policy
# feature — distinct from distribution_policy_target_shape (which is about zones).
module "mig" {
  source = "../../../modules/compute-vm/mig"

  project_id        = var.project_id
  region            = var.region
  hostname          = "flex-mig"
  instance_template = module.instance_template.self_link
  target_size       = var.target_size

  named_ports = [{ name = "http", port = 80 }]

  instance_selections = {
    "n2"  = { machine_types = ["n2-standard-2"], rank = 0 }
    "n2d" = { machine_types = ["n2d-standard-2"], rank = 1 }
    "e2"  = { machine_types = ["e2-standard-2"], rank = 2 }
  }
}
