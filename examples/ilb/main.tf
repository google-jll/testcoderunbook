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
  name                    = "ilb-example-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "ilb-example-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/24"
}

# Backend: a regional MIG built from the compute-vm modules.
module "instance_template" {
  source = "../../modules/compute-vm/instance_template"

  project_id         = var.project_id
  region             = var.region
  subnetwork         = google_compute_subnetwork.subnet.self_link
  subnetwork_project = var.project_id
  name_prefix        = "ilb-backend"
  tags               = ["allow-ilb"]
}

module "mig" {
  source = "../../modules/compute-vm/mig"

  project_id        = var.project_id
  region            = var.region
  hostname          = "ilb-backend"
  instance_template = module.instance_template.self_link
  target_size       = 2
}

# The internal TCP load balancer in front of the MIG.
module "ilb" {
  source = "../../modules/ilb"

  project_id  = var.project_id
  region      = var.region
  name        = "example-ilb"
  network     = google_compute_network.vpc.name
  subnetwork  = google_compute_subnetwork.subnet.name
  ports       = ["80"]
  target_tags = ["allow-ilb"]

  health_check = {
    type         = "http"
    port         = 80
    request_path = "/"
  }

  backends = [
    {
      group = module.mig.instance_group
    },
  ]
}
