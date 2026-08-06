# GCP Terraform Module: Cloud Nat

This module provisions and manages **Cloud Nat** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_router`** (1 instance): `router`
- **`google_compute_router_nat`** (1 instance): `main`
- **`random_string`** (1 instance): `name_suffix`

## Usage Example

```hcl
module "cloud_nat" {
  source = "../../modules/cloud-nat"

  project_id = var.project_id
  region = var.region
  router = var.router
  subnetworks = var.subnetworks
  rules = var.rules
  # icmp_idle_timeout_sec = "30"
  # min_ports_per_vm = null
  # max_ports_per_vm = null
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
| `project_id` | The project ID to deploy to | `string` | n/a | Yes |
| `region` | The region to deploy to | `string` | n/a | Yes |
| `icmp_idle_timeout_sec` | Timeout (in seconds) for ICMP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created. | `string` | `"30"` | No |
| `min_ports_per_vm` | Minimum number of ports allocated to a VM from this NAT config. Defaults to 64 if enable_dynamic_port_allocation is false, 32 if true. Changing this forces a new NAT to be created. | `string` | `null` | No |
| `max_ports_per_vm` | Maximum number of ports allocated to a VM from this NAT. This field can only be set when enableDynamicPortAllocation is enabled.This will be ignored if enable_dynamic_port_allocation is set to false. | `string` | `null` | No |
| `name` | Defaults to 'cloud-nat-RANDOM_SUFFIX'. Changing this forces a new NAT to be created. | `string` | `""` | No |
| `nat_ips` | List of self_links of external IPs. Changing this forces a new NAT to be created. Value of `nat_ip_allocate_option` is inferred based on nat_ips. If present set to MANUAL_ONLY, otherwise AUTO_ONLY. | `list(string)` | `[]` | No |
| `drain_nat_ips` | A list of URLs of the IP resources to be drained. These IPs must be valid static external IPs that have been assigned to the NAT. | `list(string)` | `[]` | No |
| `network` | VPN name, only if router is being created by the module. | `string` | `""` | No |
| `create_router` | Create router instead of using an existing one, uses 'router' variable for new resource name. | `bool` | `false` | No |
| `router` | The name of the router in which this NAT will be configured. Changing this forces a new NAT to be created. | `string` | n/a | Yes |
| `router_asn` | Router ASN, only used when create_router is true. Null (default) creates the router WITHOUT a BGP block (correct for a plain NAT gateway); set an ASN to add BGP. | `string` | `null` | No |
| `router_keepalive_interval` | Router keepalive_interval, only if router is not passed in and is created by the module. | `string` | `"20"` | No |
| `source_subnetwork_ip_ranges_to_nat` | Defaults to ALL_SUBNETWORKS_ALL_IP_RANGES. How NAT should be configured per Subnetwork. Valid values include: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, LIST_OF_SUBNETWORKS. Changing this forces a new NAT to be created. | `string` | `"ALL_SUBNETWORKS_ALL_IP_RANGES"` | No |
| `tcp_established_idle_timeout_sec` | Timeout (in seconds) for TCP established connections. Defaults to 1200s if not set. Changing this forces a new NAT to be created. | `string` | `"1200"` | No |
| `tcp_transitory_idle_timeout_sec` | Timeout (in seconds) for TCP transitory connections. Defaults to 30s if not set. Changing this forces a new NAT to be created. | `string` | `"30"` | No |
| `tcp_time_wait_timeout_sec` | Timeout (in seconds) for TCP connections that are in TIME_WAIT state. Defaults to 120s if not set. | `string` | `"120"` | No |
| `udp_idle_timeout_sec` | Timeout (in seconds) for UDP connections. Defaults to 30s if not set. Changing this forces a new NAT to be created. | `string` | `"30"` | No |
| `subnetworks` | Specifies one or more subnetwork NAT configurations | `list(object({` | n/a | Yes |
| `log_config_enable` | Indicates whether or not to export logs | `bool` | `false` | No |
| `log_config_filter` | Specifies the desired filtering of logs on this NAT. Valid values are: \ | `string` | `"ALL"` | No |
| `enable_dynamic_port_allocation` | Enable Dynamic Port Allocation. If minPorts is set, minPortsPerVm must be set to a power of two greater than or equal to 32. | `bool` | `false` | No |
| `enable_endpoint_independent_mapping` | Specifies if endpoint independent mapping is enabled. | `bool` | `false` | No |
| `rules` | Specifies one or more rules associated with this NAT. | `list(object({` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `name` | Name of the Cloud NAT |
| `nat_ip_allocate_option` | NAT IP allocation mode |
| `region` | Cloud NAT region |
| `router_name` | Cloud NAT router name |
