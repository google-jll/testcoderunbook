# GCP Terraform Module: Compute Vm - Compute Instance

This module provisions and manages **Compute Vm - Compute Instance** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_instance_from_template`** (1 instance): `compute_instance`

## Usage Example

```hcl
module "compute_instance" {
  source = "../../modules/compute-vm/compute_instance"

  project_id = var.project_id
  access_config = var.access_config
  ipv6_access_config = var.ipv6_access_config
  instance_template = var.instance_template
  alias_ip_ranges = var.alias_ip_ranges
  # network = ""
  # subnetwork = ""
  # subnetwork_project = ""
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
| `project_id` | The ID of the project in which the compute instance will be created. | `string` | n/a | Yes |
| `network` | Network to deploy to. Only one of network or subnetwork should be specified. | `string` | `""` | No |
| `subnetwork` | Subnet to deploy to. Only one of network or subnetwork should be specified. | `string` | `""` | No |
| `subnetwork_project` | The project that subnetwork belongs to | `string` | `""` | No |
| `hostname` | Hostname of instances | `string` | `""` | No |
| `add_hostname_suffix` | Adds a suffix to the hostname | `bool` | `true` | No |
| `static_ips` | List of static IPs for VM instances | `list(string)` | `[]` | No |
| `access_config` | Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet. | `list(object({` | n/a | Yes |
| `ipv6_access_config` | IPv6 access configurations. Currently a max of 1 IPv6 access configuration is supported. If not specified, the instance will have no external IPv6 Internet access. | `list(object({` | n/a | Yes |
| `num_instances` | Number of instances to create. This value is ignored if static_ips is provided. | `number` | `1` | No |
| `instance_template` | Instance template self_link used to create compute instances | `string` | n/a | Yes |
| `region` | Region where the instances should be created. | `string` | `null` | No |
| `zone` | Zone where the instances should be created. If not specified, instances will be spread across available zones in the region. | `string` | `null` | No |
| `hostname_suffix_separator` | Separator character to compose hostname when add_hostname_suffix is set to true. | `string` | `"-"` | No |
| `deletion_protection` | Enable deletion protection on this instance. Note: you must disable deletion protection before removing the resource, or the instance cannot be deleted and the Terraform run will not complete successfully. | `bool` | `false` | No |
| `alias_ip_ranges` | (Optional) An array of alias IP ranges for this network interface. Can only be specified for network interfaces on subnet-mode networks. | `list(object({` | n/a | Yes |
| `resource_policies` | (Optional) A list of short names or self_links of resource policies to attach to the instance. Modifying this list will cause the instance to recreate. Currently a max of 1 resource policy is supported. | `list(string)` | `[]` | No |
| `labels` | (Optional) Labels to override those from the template, provided as a map | `map(string)` | `null` | No |
| `resource_manager_tags` | (Optional) A tag is a key-value pair that can be attached to a Google Cloud resource. You can use tags to conditionally allow or deny policies based on whether a resource has a specific tag. This value is not returned by the API. In Terraform, this value cannot be updated and changing it will recreate the resource. | `map(string)` | `null` | No |

## Outputs

| Name | Description |
|------|-------------|
| `instances_self_links` | List of self-links for compute instances |
| `instances_details` | List of all details for compute instances |
| `available_zones` | List of available zones in region |
| `service_account_email` | The service account email associated with the instances. |
| `instance_name` | The name of the first compute instance. |
