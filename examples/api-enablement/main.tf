provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

module "api_enablement" {
  source = "../../modules/api-enablement"

  project_id                  = var.project_id
  activate_apis               = var.activate_apis
  disable_services_on_destroy = var.disable_services_on_destroy
  disable_dependent_services  = var.disable_dependent_services
}
