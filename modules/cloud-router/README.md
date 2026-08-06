# GCP Terraform Module: Cloud Router

This module provisions and manages **Cloud Router** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_router`** (1 instance): `router`
- **`google_compute_router_nat`** (1 instance): `nats`

## Usage Example

```hcl
module "cloud_router" {
  source = "../../modules/cloud-router"

  name = var.name
  network = var.network
  project_id = var.project_id
  region = var.region
  bgp = var.bgp
  nats = var.nats
  # description = null
  # encrypted_interconnect_router = false
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
| `name` | Name of the router | `string` | n/a | Yes |
| `network` | A reference to the network to which this router belongs | `string` | n/a | Yes |
| `project_id` | The project ID to deploy to | `string` | n/a | Yes |
| `region` | Region where the router resides | `string` | n/a | Yes |
| `description` | An optional description of this resource | `string` | `null` | No |
| `encrypted_interconnect_router` | An optional field to indicate if a router is dedicated to use with encrypted Interconnect Attachment | `bool` | `false` | No |
| `bgp` | BGP information specific to this router. | `object({` | n/a | Yes |
| `nats` | NATs to deploy on this router. | `list(object({` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `router` | Created Router |
| `nat` | Created NATs |
