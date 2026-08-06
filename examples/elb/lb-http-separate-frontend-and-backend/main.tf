resource "google_compute_network" "default" {
  name                    = "lb-http-separate-frontend-and-backend"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "group1" {
  name                     = "lb-http-separate-frontend-and-backend-group1"
  ip_cidr_range            = "10.126.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = "us-west1"
  private_ip_google_access = true
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group1" {
  name    = "lb-http-separate-frontend-and-backend-gw-group1"
  network = google_compute_network.default.self_link
  region  = "us-west1"
}

module "cloud-nat-group1" {
  source     = "../../../modules/cloud-nat"
  router     = google_compute_router.group1.name
  project_id = var.project_id
  region     = "us-west1"
  name       = "lb-http-separate-frontend-and-backend-cloud-nat-group1"
}

resource "google_compute_subnetwork" "group2" {
  name                     = "lb-http-separate-frontend-and-backend-group2"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = "us-west1"
  private_ip_google_access = true
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group2" {
  name    = "lb-http-separate-frontend-and-backend-gw-group2"
  network = google_compute_network.default.self_link
  region  = "us-west1"
}

module "cloud-nat-group2" {
  source     = "../../../modules/cloud-nat"
  router     = google_compute_router.group2.name
  project_id = var.project_id
  region     = "us-west1"
  name       = "lb-http-separate-frontend-and-backend-cloud-nat-group2"
}

module "lb-http-backend" {
  source = "../../../modules/elb/backend"

  project_id = var.project_id
  name       = "backend-lb"
  target_tags = [
    "lb-http-separate-frontend-and-backend-group1",
    module.cloud-nat-group1.router_name,
    "lb-http-separate-frontend-and-backend-group2",
    module.cloud-nat-group2.router_name
  ]
  firewall_networks = [google_compute_network.default.name]
  protocol          = "HTTP"
  port_name         = "http"
  timeout_sec       = 10
  enable_cdn        = false

  health_check = {
    request_path = "/"
    port         = 80
  }

  log_config = {
    enable      = true
    sample_rate = 1.0
  }

  groups = [
    {
      group = module.mig1.instance_group
    },
    {
      group = module.mig2.instance_group
    },
  ]

  iap_config = {
    enable = false
  }
}

module "lb-http-frontend" {
  source        = "../../../modules/elb/frontend"
  project_id    = var.project_id
  name          = "frontend-lb"
  url_map_input = module.lb-http-backend.backend_service_info
}
