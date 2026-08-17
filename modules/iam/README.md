# IAM

IAM role-binding and workload identity building blocks. Each module is standalone in its own directory. Compose them in your root/deploy config (see [`examples/iam`](../../examples/iam)).

## Modules

| Module | Description |
|--------|-------------|
| [`projects_iam`](./projects_iam) | Manage IAM role bindings on one or more projects. |
| [`folders_iam`](./folders_iam) | Manage IAM role bindings on one or more folders. |
| [`service-account`](./service-account) | Manage GCP Service Accounts and project-level role assignments. |
| [`workload-identity-pool`](./workload-identity-pool) | Manage Workload Identity Pools, Identity Providers (OIDC, AWS, SAML), and Service Account impersonation bindings. |
| [`helper`](./helper) | Shared helper that expands bindings; used by the binding modules. |

## Usage

```hcl
module "workload_identity_pool" {
  source = "../../modules/iam/workload-identity-pool"

  project_id   = "my-project-id"
  pool_id      = "github-actions-pool"
  display_name = "GitHub Actions Workload Identity Pool"

  providers = {
    "github-provider" = {
      display_name = "GitHub Actions Provider"
      attribute_mapping = {
        "google.subject"       = "assertion.sub"
        "attribute.repository" = "assertion.repository"
      }
      oidc = {
        issuer_uri = "https://token.actions.githubusercontent.com"
      }
    }
  }
}
```
