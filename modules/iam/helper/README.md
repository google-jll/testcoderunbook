# GCP Terraform Module: Iam - Helper

This module provisions and manages **Iam - Helper** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module acts as an orchestration helper or configuration wrapper.

## Usage Example

```hcl
module "helper" {
  source = "../../modules/iam/helper"

  entities = var.entities
  conditional_bindings = var.conditional_bindings
  # bindings = {
  # mode = "additive"
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
| `entities` | Entities list to add the IAM policies/bindings | `list(string)` | n/a | Yes |
| `bindings` | Map of role (key) and list of members (value) to add the IAM policies/bindings | `map(list(string))` | `{}` | No |
| `conditional_bindings` | List of maps of role and respective conditions, and the members to add the IAM policies/bindings | `list(object({ role = string title = string description = string expression = string members = list(string) }))` | `[ ]` | No |
| `mode` | Mode for adding the IAM policies/bindings, additive and authoritative | `string` | `"additive"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `bindings_additive` | Map of additive bindings for entities. Unwinded by members. |
| `bindings_authoritative` | Map of authoritative bindings for entities. Unwinded by roles. |
| `bindings_by_member` | List of bindings for entities unwinded by members. |
| `set_additive` | A set of additive binding keys (from bindings_additive) to be used in for_each. Unwinded by members. |
| `set_authoritative` | A set of authoritative binding keys (from bindings_authoritative) to be used in for_each. Unwinded by roles. |
