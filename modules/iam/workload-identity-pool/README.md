# GCP Workload Identity Pool Terraform Module

This module provisions and manages **Google Cloud Workload Identity Pools** and **Workload Identity Pool Providers** (supporting OIDC, AWS, and SAML federation) along with Service Account Workload Identity User IAM bindings following Google Cloud enterprise security standards.

Workload Identity Federation allows external workloads (such as GitHub Actions, GitLab CI/CD, AWS EC2/EKS, Azure VMs/AKS, Kubernetes clusters, or SAML IDPs) to authenticate directly to Google Cloud without storing long-lived service account key files.

## Features & Supported Use Cases

- **Keyless Authentication**: Eliminates static, long-lived service account JSON keys.
- **Multi-Provider Support**: Supports **OIDC** (GitHub Actions, GitLab, Azure AD, EKS), **AWS IAM**, and **SAML 2.0**.
- **Attribute Mapping & Conditions**: Map identity provider claims to Google Cloud attributes and apply CEL attribute conditions (e.g. restrict to specific GitHub repositories or Azure tenants).
- **Service Account Impersonation**: Easily configure `roles/iam.workloadIdentityUser` IAM member bindings to allow federated external principals to exchange short-lived tokens and impersonate GCP Service Accounts.

## Resources Provisioned

- **`google_iam_workload_identity_pool`** (1 instance): Main identity pool
- **`google_iam_workload_identity_pool_provider`** (dynamic): Identity provider configurations (OIDC, AWS, SAML)
- **`google_service_account_iam_member`** (dynamic): IAM bindings granting `roles/iam.workloadIdentityUser` to external workload identity principals

## Usage Examples

### 1. GitHub Actions (OIDC)

```hcl
module "workload_identity_pool" {
  source = "../../modules/iam/workload-identity-pool"

  project_id   = "my-gcp-project"
  pool_id      = "github-actions-pool"
  display_name = "GitHub Actions Pool"
  description  = "Workload Identity Pool for GitHub Actions workflows"

  workload_identity_pool_providers = {
    "github-provider" = {
      display_name        = "GitHub Provider"
      attribute_condition = "assertion.repository_owner == \"my-org\""
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
    "github_deployer" = {
      service_account_id = "projects/my-gcp-project/serviceAccounts/deployer-sa@my-gcp-project.iam.gserviceaccount.com"
      roles              = ["roles/iam.workloadIdentityUser"]
      workload_identity_principals = [
        "principalSet://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/my-org/my-repo"
      ]
    }
  }
}
```

### 2. AWS IAM Federation

```hcl
module "aws_workload_identity_pool" {
  source = "../../modules/iam/workload-identity-pool"

  project_id   = "my-gcp-project"
  pool_id      = "aws-federation-pool"
  display_name = "AWS Workload Pool"

  workload_identity_pool_providers = {
    "aws-provider" = {
      display_name = "AWS Account Provider"
      attribute_mapping = {
        "google.subject"        = "assertion.arn"
        "attribute.aws_account" = "assertion.account"
      }
      aws = {
        account_id = "123456789012"
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.3` |
| **Google Cloud Provider** | `>= 5.0, < 8` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `pool_id` | The ID of the Workload Identity Pool. Must be 1-32 characters long, contain only lowercase letters, numbers, and hyphens. | `string` | n/a | Yes |
| `project_id` | The GCP project ID where the Workload Identity Pool will be created. | `string` | n/a | Yes |
| `description` | A description of the Workload Identity Pool. | `string` | `null` | No |
| `disabled` | Whether the Workload Identity Pool is disabled. | `bool` | `false` | No |
| `display_name` | A display name for the Workload Identity Pool (must be 32 characters or fewer). | `string` | `null` | No |
| `sa_bindings` | Map of Service Account Workload Identity bindings to grant external workloads permission to impersonate GCP Service Accounts. service_account_id can be a plain email address or a full resource URI. | `map(object({ service_account_id = string roles = optional(list(string), ["roles/iam.workloadIdentityUser"]) workload_identity_principals = list(string) }))` | `{}` | No |
| `workload_identity_pool_providers` | Map of Workload Identity Pool Provider configurations. Key is the provider ID. | `map(object({ provider_id = optional(string) display_name = optional(string) description = optional(string) disabled = optional(bool, false) attribute_mapping = map(string) attribute_condition = optional(string) oidc = optional(object({ issuer_uri = string allowed_audiences = optional(list(string)) jwks_json = optional(string) })) aws = optional(object({ account_id = string })) saml = optional(object({ idp_metadata_xml = string })) }))` | `{}` | No |
## Outputs

| Name | Description |
|------|-------------|
| `pool_id` | The Workload Identity Pool ID. |
| `pool_name` | The resource name of the Workload Identity Pool in the format 'projects/{project}/locations/global/workloadIdentityPools/{pool_id}'. |
| `pool_state` | The state of the Workload Identity Pool. |
| `project_number` | The numeric GCP project number. |
| `provider_ids` | Map of provider IDs created in the Workload Identity Pool. |
| `provider_names` | Map of full resource names of the Workload Identity Pool Providers. |
