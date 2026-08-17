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
| `bgp` | BGP information specific to this router. | `object({ asn = string advertise_mode = optional(string, "CUSTOM") advertised_groups = optional(list(string)) advertised_ip_ranges = optional(list(object({ range = string description = optional(string) })), []) keepalive_interval = optional(number) })` | `null` | No |
| `description` | An optional description of this resource | `string` | `null` | No |
| `encrypted_interconnect_router` | An optional field to indicate if a router is dedicated to use with encrypted Interconnect Attachment | `bool` | `false` | No |
| `nats` | NATs to deploy on this router. | `list(object({ name = string nat_ip_allocate_option = optional(string) source_subnetwork_ip_ranges_to_nat = optional(string) nat_ips = optional(list(string), []) drain_nat_ips = optional(list(string), []) min_ports_per_vm = optional(number) max_ports_per_vm = optional(number) udp_idle_timeout_sec = optional(number) icmp_idle_timeout_sec = optional(number) tcp_established_idle_timeout_sec = optional(number) tcp_transitory_idle_timeout_sec = optional(number) tcp_time_wait_timeout_sec = optional(number) enable_endpoint_independent_mapping = optional(bool) enable_dynamic_port_allocation = optional(bool) log_config = optional(object({ enable = optional(bool, true) filter = optional(string, "ALL") }), {}) subnetworks = optional(list(object({ name = string source_ip_ranges_to_nat = list(string) secondary_ip_range_names = optional(list(string)) })), []) }))` | `[]` | No |
## Outputs

| Name | Description |
|------|-------------|
| `nat` | Created NATs |
| `router` | Created Router |
