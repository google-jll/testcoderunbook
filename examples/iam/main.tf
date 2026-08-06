provider "google" {}

# Project-level IAM bindings.
module "projects_iam" {
  source = "../../modules/iam/projects_iam"

  projects = var.projects
  mode     = "additive"

  bindings = {
    "roles/viewer" = var.viewer_members
  }
}

# Folder-level IAM bindings.
module "folders_iam" {
  source = "../../modules/iam/folders_iam"

  folders = var.folders
  mode    = "additive"

  bindings = {
    "roles/resourcemanager.folderViewer" = var.viewer_members
  }
}
