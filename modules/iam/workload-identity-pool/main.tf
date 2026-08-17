data "google_project" "project" {
  project_id = var.project_id
}

# Provisions a Google Cloud Workload Identity Pool for external workload authentication
resource "google_iam_workload_identity_pool" "pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = var.display_name
  description               = var.description
  disabled                  = var.disabled
}

# Provisions optional Workload Identity Pool Providers (OIDC, AWS, SAML)
resource "google_iam_workload_identity_pool_provider" "providers" {
  for_each = var.workload_identity_pool_providers

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = coalesce(each.value.provider_id, each.key)
  display_name                       = each.value.display_name
  description                        = each.value.description
  disabled                           = coalesce(each.value.disabled, false)
  attribute_mapping                  = each.value.attribute_mapping
  attribute_condition                = each.value.attribute_condition

  dynamic "oidc" {
    for_each = each.value.oidc != null ? [each.value.oidc] : []
    content {
      issuer_uri        = oidc.value.issuer_uri
      allowed_audiences = oidc.value.allowed_audiences
      jwks_json         = oidc.value.jwks_json
    }
  }

  dynamic "aws" {
    for_each = each.value.aws != null ? [each.value.aws] : []
    content {
      account_id = aws.value.account_id
    }
  }

  dynamic "saml" {
    for_each = each.value.saml != null ? [each.value.saml] : []
    content {
      idp_metadata_xml = saml.value.idp_metadata_xml
    }
  }
}

locals {
  sa_bindings_flat = flatten([
    for k, v in var.sa_bindings : [
      for principal in v.workload_identity_principals : [
        for role in coalesce(v.roles, ["roles/iam.workloadIdentityUser"]) : {
          key                = "${k}-${role}-${principal}"
          service_account_id = startswith(v.service_account_id, "projects/") ? v.service_account_id : "projects/${var.project_id}/serviceAccounts/${v.service_account_id}"
          role               = role
          member             = replace(principal, "projects/${var.project_id}/", "projects/${data.google_project.project.number}/")
        }
      ]
    ]
  ])
}

# Grants external workload identity principals permissions (e.g. roles/iam.workloadIdentityUser) to impersonate GCP Service Accounts
resource "google_service_account_iam_member" "workload_identity_users" {
  for_each = { for b in local.sa_bindings_flat : b.key => b }

  service_account_id = each.value.service_account_id
  role               = each.value.role
  member             = each.value.member

  depends_on = [
    google_iam_workload_identity_pool.pool,
    google_iam_workload_identity_pool_provider.providers
  ]
}
