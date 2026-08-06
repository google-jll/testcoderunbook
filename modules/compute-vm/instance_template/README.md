# GCP Terraform Module: Compute Vm - Instance Template

This module provisions and manages **Compute Vm - Instance Template** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_instance_template`** (1 instance): `tpl`
- **`google_project_iam_member`** (1 instance): `roles`
- **`google_service_account`** (1 instance): `sa`

## Usage Example

```hcl
module "instance_template" {
  source = "../../modules/compute-vm/instance_template"

  project_id = var.project_id
  region = var.region
  additional_disks = var.additional_disks
  subnets = var.subnets
  additional_networks_str = var.additional_networks_str
  service_account = var.service_account
  shielded_instance_config = var.shielded_instance_config
  access_config = var.access_config
  ipv6_access_config = var.ipv6_access_config
  gpu = var.gpu
  alias_ip_range = var.alias_ip_range
  resource_manager_tags = var.resource_manager_tags
  # name_prefix = "default-instance-template"
  # machine_type = "n1-standard-1"
  # spot = false
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
| `project_id` | The GCP project ID | `string` | n/a | Yes |
| `region` | Region where the instance template should be created. | `string` | n/a | Yes |
| `name_prefix` | Name prefix for the instance template | `string` | `"default-instance-template"` | No |
| `machine_type` | Machine type to create, e.g. n1-standard-1 | `string` | `"n1-standard-1"` | No |
| `spot` | Provision a SPOT instance | `bool` | `false` | No |
| `description` | The template's description | `string` | `""` | No |
| `instance_description` | Description of the generated instances | `string` | `""` | No |
| `min_cpu_platform` | Specifies a minimum CPU platform. Applicable values are the friendly names of CPU platforms, such as Intel Haswell or Intel Skylake. See the complete list: https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform | `string` | `null` | No |
| `can_ip_forward` | Enable IP forwarding, for NAT instances for example | `string` | `"false"` | No |
| `tags` | Network tags, provided as a list | `list(string)` | `[]` | No |
| `labels` | Labels, provided as a map | `map(string)` | `{` | No |
| `preemptible` | Allow the instance to be preempted | `bool` | `false` | No |
| `automatic_restart` | (Optional) Specifies whether the instance should be automatically restarted if it is terminated by Compute Engine (not terminated by a user). | `bool` | `true` | No |
| `maintenance_interval` | Specifies the frequency of planned maintenance events | `string` | `null` | No |
| `on_host_maintenance` | Instance availability Policy | `string` | `"MIGRATE"` | No |
| `spot_instance_termination_action` | Action to take when Compute Engine preempts a Spot VM. | `string` | `"STOP"` | No |
| `enable_nested_virtualization` | Defines whether the instance should have nested virtualization enabled. | `bool` | `false` | No |
| `threads_per_core` | The number of threads per physical core. To disable simultaneous multithreading (SMT) set this to 1. | `number` | `null` | No |
| `resource_policies` | A list of self_links of resource policies to attach to the instance. Modifying this list will cause the instance to recreate. Currently a max of 1 resource policy is supported. | `list(string)` | `[]` | No |
| `source_image` | Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public Rocky Linux 9 optimized for GCP image. | `string` | `""` | No |
| `source_image_family` | Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Rocky Linux 9 optimized for GCP image. | `string` | `"rocky-linux-9-optimized-gcp"` | No |
| `source_image_project` | Project where the source image comes from. The default project contains Rocky Linux images. | `string` | `"rocky-linux-cloud"` | No |
| `disk_size_gb` | Boot disk size in GB | `string` | `"100"` | No |
| `disk_type` | Boot disk type, can be either pd-ssd, local-ssd, or pd-standard | `string` | `"pd-standard"` | No |
| `disk_labels` | Labels to be assigned to boot disk, provided as a map | `map(string)` | `{` | No |
| `disk_encryption_key` | The id of the encryption key that is stored in Google Cloud KMS to use to encrypt all the disks on this instance | `string` | `null` | No |
| `auto_delete` | Whether or not the boot disk should be auto-deleted | `string` | `"true"` | No |
| `additional_disks` | List of maps of additional disks. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#disk_name | `list(object({` | n/a | Yes |
| `disk_resource_policies` | A list (short name or id) of resource policies to attach to this disk for automatic snapshot creations | `list(string)` | `[]` | No |
| `network` | The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks. | `string` | `""` | No |
| `subnetwork` | The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided. | `string` | `""` | No |
| `subnetwork_project` | The ID of the project in which the subnetwork belongs. If it is not provided, the provider project is used. | `string` | `""` | No |
| `network_attachment` | The self_link of the network attachment for PSC-I connection. | `string` | `null` | No |
| `subnets` | Optional: A map containing subnet details Used to derive the subnetwork URI if subnetwork is not provided. | `list(object({` | n/a | Yes |
| `network_ip` | Private IP address to assign to the instance if desired. | `string` | `""` | No |
| `nic_type` | Valid values are \ | `string` | `null` | No |
| `stack_type` | The stack type for this network interface to identify whether the IPv6 feature is enabled or not. Values are `IPV4_IPV6` or `IPV4_ONLY`. Default behavior is equivalent to IPV4_ONLY. | `string` | `null` | No |
| `additional_networks_str` | Additional network interface details for GCE provided as a JSON-encoded string. Expected format: '[{\ | `string` | n/a | Yes |
| `additional_networks` | Additional network interface details for GCE, if any. | `list(object({` | `[]` | No |
| `total_egress_bandwidth_tier` | Egress bandwidth tier setting for supported VM families | `string` | `"DEFAULT"` | No |
| `startup_script` | User startup script to run when instances spin up | `string` | `""` | No |
| `metadata` | Metadata, provided as a map | `map(string)` | `{` | No |
| `service_account` | n/a | `object({` | n/a | Yes |
| `create_service_account` | Create a new service account to attach to the instance. This is alternate to providing the service_account input variable. Please provide the service_account input if setting this to false. | `bool` | `true` | No |
| `service_account_project_roles` | Roles to grant to the newly created cloud run SA in specified project. Should be used with create_service_account set to true and no input for service_account | `list(string)` | `[]` | No |
| `enable_shielded_vm` | Whether to enable the Shielded VM configuration on the instance. Note that the instance image must support Shielded VMs. See https://cloud.google.com/compute/docs/images | `bool` | `false` | No |
| `shielded_instance_config` | Not used unless enable_shielded_vm is true. Shielded VM configuration for the instance. | `object({` | n/a | Yes |
| `enable_confidential_vm` | Whether to enable the Confidential VM configuration on the instance. Note that the instance image must support Confidential VMs. See https://cloud.google.com/compute/docs/images | `bool` | `false` | No |
| `confidential_instance_type` | Defines the confidential computing technology the instance uses. If this is set to \ | `string` | `null` | No |
| `access_config` | Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet. | `list(object({` | n/a | Yes |
| `ipv6_access_config` | IPv6 access configurations. Currently a max of 1 IPv6 access configuration is supported. If not specified, the instance will have no external IPv6 Internet access. | `list(object({` | n/a | Yes |
| `gpu` | GPU information. Type and count of GPU to attach to the instance template. See https://cloud.google.com/compute/docs/gpus more details | `object({` | n/a | Yes |
| `alias_ip_range` | n/a | `object({` | n/a | Yes |
| `resource_manager_tags` | n/a | `string` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `self_link_unique` | Unique self-link of instance template (recommended output to use instead of self_link) |
| `self_link` | Self-link of instance template |
| `name` | Name of instance template |
| `tags` | Tags that will be associated with instance(s) |
| `service_account_info` | Service account id and email |
| `network_interface_details` | The names of the template interfaces. |
