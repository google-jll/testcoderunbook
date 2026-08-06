provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

locals {
  # Minimal startup script (replaces the upstream gceme.sh.tpl + template_file
  # data source, which required the deprecated hashicorp/template provider).
  startup_script = <<-EOT
    #!/bin/bash
    echo "hello from $(hostname)" > /var/www/html/index.html
  EOT
}

module "mig1_template" {
  source     = "../../../modules/compute-vm/instance_template"
  project_id = var.project_id
  region     = "us-west1"
  network    = google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.group1.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix          = "lb-http-separate-frontend-and-backend-group1"
  startup_script       = local.startup_script
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  tags = [
    "lb-http-separate-frontend-and-backend-group1",
    module.cloud-nat-group1.router_name
  ]
}

module "mig1" {
  source            = "../../../modules/compute-vm/mig"
  project_id        = var.project_id
  instance_template = module.mig1_template.self_link
  region            = "us-west1"
  hostname          = "lb-http-separate-frontend-and-backend-group1"
  target_size       = 2
  named_ports = [{
    name = "http",
    port = 80
  }]
}

module "mig2_template" {
  source     = "../../../modules/compute-vm/instance_template"
  project_id = var.project_id
  region     = "us-west1"
  network    = google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.group2.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix    = "lb-http-separate-frontend-and-backend-group2"
  startup_script = local.startup_script
  tags = [
    "lb-http-separate-frontend-and-backend-group2",
    module.cloud-nat-group2.router_name
  ]
}

module "mig2" {
  source            = "../../../modules/compute-vm/mig"
  project_id        = var.project_id
  instance_template = module.mig2_template.self_link
  region            = "us-west1"
  hostname          = "lb-http-separate-frontend-and-backend-group2"
  target_size       = 2
  named_ports = [{
    name = "http",
    port = 80
  }]
}
