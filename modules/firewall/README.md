# GCP Terraform Module: Firewall

This module provisions and manages **Firewall** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_firewall`** (2 instances): `rules`, `rules_ingress_egress`

## Usage Example

```hcl
module "firewall" {
  source = "../../modules/firewall"

  project_id = var.project_id
  network_name = var.network_name
  # rules = []
  # ingress_rules = []
  # egress_rules = []
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
| `network_name` | Name of the network this set of firewall rules applies to. | `string` | n/a | Yes |
| `project_id` | Project id of the project that holds the network. | `string` | n/a | Yes |
| `egress_rules` | List of egress rules. This will be ignored if variable 'rules' is non-empty | `list(object({ name = string description = optional(string, null) disabled = optional(bool, null) priority = optional(number, null) destination_ranges = optional(list(string), []) source_ranges = optional(list(string), []) source_tags = optional(list(string)) source_service_accounts = optional(list(string)) target_tags = optional(list(string)) target_service_accounts = optional(list(string)) allow = optional(list(object({ protocol = string ports = optional(list(string)) })), []) deny = optional(list(object({ protocol = string ports = optional(list(string)) })), []) log_config = optional(object({ metadata = string })) }))` | `[]` | No |
| `ingress_rules` | List of ingress rules. This will be ignored if variable 'rules' is non-empty | `list(object({ name = string description = optional(string, null) disabled = optional(bool, null) priority = optional(number, null) destination_ranges = optional(list(string), []) source_ranges = optional(list(string), []) source_tags = optional(list(string)) source_service_accounts = optional(list(string)) target_tags = optional(list(string)) target_service_accounts = optional(list(string)) allow = optional(list(object({ protocol = string ports = optional(list(string)) })), []) deny = optional(list(object({ protocol = string ports = optional(list(string)) })), []) log_config = optional(object({ metadata = string })) }))` | `[]` | No |
| `rules` | This is DEPRECATED and available for backward compatibility. Use ingress_rules and egress_rules variables. List of custom rule definitions | `list(object({ name = string description = optional(string, null) direction = optional(string, "INGRESS") disabled = optional(bool, null) priority = optional(number, null) ranges = optional(list(string), []) source_tags = optional(list(string)) source_service_accounts = optional(list(string)) target_tags = optional(list(string)) target_service_accounts = optional(list(string)) allow = optional(list(object({ protocol = string ports = optional(list(string)) })), []) deny = optional(list(object({ protocol = string ports = optional(list(string)) })), []) log_config = optional(object({ metadata = string })) }))` | `[]` | No |
## Outputs

| Name | Description |
|------|-------------|
| `firewall_rules` | The created firewall rule resources |
| `firewall_rules_ingress_egress` | The created firewall ingress/egress rule resources |
