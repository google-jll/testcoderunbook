provider "google" {
  project = var.project_id
}

module "health_check" {
  source = "../../modules/health-check"

  project_id   = var.project_id
  name         = "example-http-health-check"
  type         = "http"
  port         = 80
  request_path = "/healthz"
}
