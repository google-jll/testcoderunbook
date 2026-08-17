provider "google" {
  project = var.project_id
}

# Create a Service Account to receive Workload Identity User impersonation permissions
module "service_account" {
  count = var.create_service_account ? 1 : 0

  source = "../../../modules/iam/service-account"

  project_id   = var.project_id
  account_id   = var.service_account_id
  display_name = "GitHub Deployer Service Account"
}

locals {
  target_sa_id = var.create_service_account ? module.service_account[0].email : var.service_account_id
}

# Deploy Workload Identity Pool and Provider for multi-cloud / CI/CD federation
module "workload_identity_pool" {
  source = "../../../modules/iam/workload-identity-pool"

  project_id   = var.project_id
  pool_id      = var.pool_id
  display_name = "GitHub Actions Workload Pool"
  description  = "Workload Identity Pool for GitHub Actions OIDC authentication and AWS federation"

  workload_identity_pool_providers = {
    "github-provider" = {
      display_name        = "GitHub Actions Provider"
      description         = "OIDC identity provider for GitHub Actions CI/CD workflows"
      attribute_condition = "assertion.repository_owner == 'my-org'"
      attribute_mapping = {
        "google.subject"             = "assertion.sub"
        "attribute.actor"            = "assertion.actor"
        "attribute.repository"       = "assertion.repository"
        "attribute.repository_owner" = "assertion.repository_owner"
      }
      oidc = {
        issuer_uri = "https://token.actions.githubusercontent.com"
      }
    }
  }

  sa_bindings = {
    "github_actions_sa_binding" = {
      service_account_id = local.target_sa_id
      roles              = ["roles/iam.workloadIdentityUser"]
      workload_identity_principals = [
        "principalSet://iam.googleapis.com/projects/${var.project_id}/locations/global/workloadIdentityPools/${var.pool_id}/attribute.repository/${var.github_repo}"
      ]
    }
  }
}
