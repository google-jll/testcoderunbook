provider "google" {
  project = var.project_id
}

module "sa" {
  source = "../../../modules/iam/service-account"

  project_id   = var.project_id
  account_id   = "example-app-sa"
  display_name = "Example application service account"

  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}
