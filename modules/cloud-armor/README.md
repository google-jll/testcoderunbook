# GCP Terraform Module: Cloud Armor

This module provisions and manages **Cloud Armor** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_security_policy`** (1 instance): `policy`

## Usage Example

```hcl
module "cloud_armor" {
  source = "../../modules/cloud-armor"

  project_id = var.project_id
  policy_name = var.policy_name
  allowed_ip_ranges = var.allowed_ip_ranges
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
| `allowed_ip_ranges` | List of whitelisted IP ranges isolated as parameterized variables. | `list(string)` | n/a | Yes |
| `policy_name` | The name of the Cloud Armor security policy. | `string` | n/a | Yes |
| `project_id` | The ID of the GCP project in which to provision the Cloud Armor policy. | `string` | n/a | Yes |
## Outputs

| Name | Description |
|------|-------------|
| `policy_id` | The ID of the created Cloud Armor security policy. |
| `policy_name` | Cloud Armor security policy name. |
| `policy_self_link` | The URI of the created Cloud Armor security policy. |
