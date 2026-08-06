provider "google" {}

module "folders" {
  source = "../../modules/folders"

  parent = var.parent

  names = [
    "dev",
    "staging",
    "prod",
  ]
}
