provider "google" {
  project = var.project_id
  region  = "us-west1" # Primary regional deployment locked strictly to Dammam, KSA.
}

module "cloud_armor_whitelist" {
  source = "../../modules/cloud-armor"

  project_id        = var.project_id
  policy_name       = var.policy_name
  allowed_ip_ranges = var.allowed_ip_ranges
}