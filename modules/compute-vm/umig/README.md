# GCP Terraform Module: Compute Vm - Umig

This module provisions and manages **Compute Vm - Umig** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_instance_from_template`** (1 instance): `compute_instance`
- **`google_compute_instance_group`** (1 instance): `instance_group`

## Usage Example

```hcl
module "umig" {
  source = "../../modules/compute-vm/umig"

  region = var.region
  named_ports = var.named_ports
  instance_template = var.instance_template
  access_config = var.access_config
  ipv6_access_config = var.ipv6_access_config
  # project_id = null
  # network = ""
  # subnetwork = ""
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
| `project_id` | The GCP project ID | `string` | `null` | No |
| `network` | Network to deploy to. Only one of network or subnetwork should be specified. | `string` | `""` | No |
| `region` | The GCP region where the unmanaged instance group resides. | `string` | n/a | Yes |
| `subnetwork` | Subnet to deploy to. Only one of network or subnetwork should be specified. | `string` | `""` | No |
| `subnetwork_project` | The project that subnetwork belongs to | `string` | `""` | No |
| `additional_networks` | Additional network interface details for GCE, if any. | `list(object({` | `[]` | No |
| `hostname` | Hostname of instances | `string` | `""` | No |
| `static_ips` | List of static IPs for VM instances | `list(string)` | `[]` | No |
| `num_instances` | Number of instances to create. This value is ignored if static_ips is provided. | `string` | `"1"` | No |
| `named_ports` | Named name and named port | `list(object({` | n/a | Yes |
| `instance_template` | Instance template self_link used to create compute instances | `string` | n/a | Yes |
| `access_config` | Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet. | `list(list(object({` | n/a | Yes |
| `ipv6_access_config` | IPv6 access configurations. Currently a max of 1 IPv6 access configuration is supported. If not specified, the instance will have no external IPv6 Internet access. | `list(list(object({` | n/a | Yes |
| `hostname_suffix_separator` | Separator character to compose hostname when add_hostname_suffix is set to true. | `string` | `"-"` | No |
| `zones` | (Optional) List of availability zones to create VM instances in | `list(string)` | `[]` | No |

## Outputs

| Name | Description |
|------|-------------|
| `self_links` | List of self-links for unmanaged instance groups |
| `umig_details` | List of all details for unmanaged instance groups |
| `instances_self_links` | List of self-links for compute instances |
| `instances_details` | List of all details for compute instances |
| `available_zones` | List of available zones in region |
