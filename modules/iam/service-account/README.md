# GCP Terraform Module: Iam - Service Account

This module provisions and manages **Iam - Service Account** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_project_iam_member`** (1 instance): `roles`
- **`google_service_account`** (1 instance): `this`

## Usage Example

```hcl
module "service_account" {
  source = "../../modules/iam/service-account"

  project_id = var.project_id
  account_id = var.account_id
  # display_name = null
  # description = null
  # project_roles = []
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
| `project_id` | Project that will own the service account and role bindings. | `string` | n/a | Yes |
| `account_id` | The account id (the part before @) of the service account, e.g. \ | `string` | n/a | Yes |
| `display_name` | Human-readable display name for the service account. | `string` | `null` | No |
| `description` | Description of the service account. | `string` | `null` | No |
| `project_roles` | Project-level IAM roles to grant to this service account (non-authoritative member bindings). | `list(string)` | `[]` | No |

## Outputs

| Name | Description |
|------|-------------|
| `email` | The service account email. |
| `id` | The service account fully-qualified id (projects/.../serviceAccounts/<email>). |
| `name` | The fully-qualified name of the service account. |
| `member` | The IAM member string (serviceAccount:<email>) for use in bindings. |
