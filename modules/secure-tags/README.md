# GCP Terraform Module: Secure Tags

This module provisions and manages **Secure Tags** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_tags_location_tag_binding`** (1 instance): `location_bindings`
- **`google_tags_tag_binding`** (1 instance): `global_bindings`
- **`google_tags_tag_key`** (1 instance): `keys`
- **`google_tags_tag_key_iam_binding`** (1 instance): `key_bindings`
- **`google_tags_tag_value`** (1 instance): `values`
- **`google_tags_tag_value_iam_binding`** (1 instance): `value_bindings`

## Usage Example

```hcl
module "secure_tags" {
  source = "../../modules/secure-tags"

  parent = var.parent
  keys = var.keys
  bindings = var.bindings
  tag_key_iam_bindings = var.tag_key_iam_bindings
  tag_value_iam_bindings = var.tag_value_iam_bindings
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
| `parent` | The parent resource where the tag keys will be created (e.g. 'organizations/123456789012' or 'projects/my-project-id' or 'projects/1234567890'). | `string` | n/a | Yes |
| `bindings` | Map of Tag Bindings to attach tag values to target resources. Set 'location' for zonal/regional resources (such as Compute Engine VM instances). | `map(object({ parent = string # Full resource URI, e.g., //compute.googleapis.com/projects/... location = optional(string) # Zone or region for zonal/regional resources (e.g. "me-central2-a"). Null for global resources. key_name = optional(string) # Key name declared in var.keys val_name = optional(string) # Value name declared under the key tag_value_id = optional(string) # Or direct tag value id: tagValues/1234567890 }))` | `{}` | No |
| `keys` | Map of Tag Keys and their nested Tag Values to create. | `map(object({ description = optional(string) purpose = optional(string) purpose_data = optional(map(string)) values = optional(map(object({ description = optional(string) })), {}) }))` | `{}` | No |
| `tag_key_iam_bindings` | List of IAM bindings for Tag Keys. | `list(object({ key_name = string role = string members = list(string) }))` | `[]` | No |
| `tag_value_iam_bindings` | List of IAM bindings for Tag Values. | `list(object({ key_name = string val_name = string role = string members = list(string) }))` | `[]` | No |
## Outputs

| Name | Description |
|------|-------------|
| `bindings` | Map of Tag Binding keys to their generated Tag Binding IDs. |
| `key_names` | Map of Tag Key short names to their full resource names. |
| `keys` | Map of Tag Key short names to their generated Tag Key IDs (e.g. tagKeys/1234567890). |
| `keys_detail` | Detailed map of all created Tag Key resources. |
| `values` | Map of composite Tag Value keys (key/value) to their generated Tag Value IDs (e.g. tagValues/1234567890). |
| `values_by_key` | Nested map of [key_name][value_name] to Tag Value ID. |
| `values_detail` | Detailed map of all created Tag Value resources. |
