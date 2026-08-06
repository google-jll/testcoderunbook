# GCP Terraform Module: Vpc

This module provisions and manages **Vpc** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_network`** (1 instance): `this`
- **`google_compute_subnetwork`** (1 instance): `this`

## Usage Example

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_id = var.project_id
  name = var.name
  subnets = var.subnets
  # description = null
  # auto_create_subnetworks = false
  # routing_mode = "REGIONAL"
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
| `project_id` | Project ID that holds the network. | `string` | n/a | Yes |
| `name` | Name of the VPC network. | `string` | n/a | Yes |
| `description` | Optional description of the network. | `string` | `null` | No |
| `auto_create_subnetworks` | Whether to create a subnet per region automatically. Keep false for a standalone/custom-mode VPC. | `bool` | `false` | No |
| `routing_mode` | Network-wide routing mode: REGIONAL or GLOBAL. | `string` | `"REGIONAL"` | No |
| `mtu` | MTU of the network (1300-8896). Null lets the provider use its default (1460). | `number` | `null` | No |
| `delete_default_routes_on_create` | Delete the default 0.0.0.0/0 internet route when the network is created. | `bool` | `false` | No |
| `network_firewall_policy_enforcement_order` | Order that firewall rules and policies are evaluated: AFTER_CLASSIC_FIREWALL (GCP default) or BEFORE_CLASSIC_FIREWALL. | `string` | `"AFTER_CLASSIC_FIREWALL"` | No |
| `subnets` | Subnets to create in this network, keyed by subnet name. | `map(object({` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `network_id` | The network id (projects/<project>/global/networks/<name>). |
| `network_self_link` | The network self link. |
| `network_name` | The network name. |
| `subnets` | Map of subnet name to its id/self_link/region/cidr. |
