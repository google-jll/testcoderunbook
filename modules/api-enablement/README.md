# GCP Terraform Module: Api Enablement

This module provisions and manages **Api Enablement** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_project_iam_member`** (1 instance): `project_service_identity_roles`
- **`google_project_service`** (1 instance): `project_services`
- **`google_project_service_identity`** (1 instance): `project_service_identities`

## Usage Example

```hcl
module "api_enablement" {
  source = "../../modules/api-enablement"

  project_id = var.project_id
  activate_api_identities = var.activate_api_identities
  # enable_apis = true
  # activate_apis = []
  # disable_services_on_destroy = true
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
| `project_id` | The GCP project you want to enable APIs on | `string` | n/a | Yes |
| `enable_apis` | Whether to actually enable the APIs. If false, this module is a no-op. | `bool` | `true` | No |
| `activate_apis` | The list of apis to activate within the project | `list(string)` | `[]` | No |
| `activate_api_identities` | n/a | `list(object({` | n/a | Yes |
| `disable_services_on_destroy` | Whether project services will be disabled when the resources are destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_on_destroy | `bool` | `true` | No |
| `disable_dependent_services` | Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_dependent_services | `bool` | `true` | No |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | The GCP project you want to enable APIs on |
| `enabled_apis` | Enabled APIs in the project |
| `enabled_api_identities` | Enabled API identities in the project |
