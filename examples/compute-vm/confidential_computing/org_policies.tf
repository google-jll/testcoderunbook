module "confidential-computing-org-policy" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 7.0"

  project_id       = var.project_id
  policy_for       = "project"
  constraint       = "constraints/compute.restrictNonConfidentialComputing"
  policy_type      = "list"
  deny             = ["compute.googleapis.com"]
  deny_list_length = 1
}

module "enforce-cmek-org-policy" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 7.0"

  project_id       = var.project_id
  policy_for       = "project"
  constraint       = "constraints/gcp.restrictNonCmekServices"
  policy_type      = "list"
  deny             = ["compute.googleapis.com"]
  deny_list_length = 1
}

module "restrict-cmek-cryptokey-projects-policy" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 7.0"

  project_id        = var.project_id
  policy_for        = "project"
  constraint        = "constraints/gcp.restrictCmekCryptoKeyProjects"
  policy_type       = "list"
  allow             = ["projects/${var.project_id}"]
  allow_list_length = 1
}
