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
| `access_config` | Access configurations, i.e. IPs via which the VM instance can be accessed via the Internet. | `list(object({ nat_ip = optional(string) network_tier = string }))` | `[]` | No |
| `additional_disks` | List of maps of additional disks. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#disk_name | `list(object({ auto_delete = optional(bool, true) boot = optional(bool, false) device_name = optional(string) disk_name = optional(string) disk_size_gb = optional(number) disk_type = optional(string) disk_labels = optional(map(string), {}) interface = optional(string) mode = optional(string) source = optional(string) source_image = optional(string) source_snapshot = optional(string) }))` | `[]` | No |
| `additional_networks` | Additional network interface details for GCE, if any. | `list(object({ network = optional(string) subnetwork = optional(string) subnetwork_project = optional(string) network_ip = optional(string) nic_type = optional(string) stack_type = optional(string) # New Fields queue_count = optional(number) # Multi-queue count (Rx/Tx) network_attachment = optional(string) # Consumer link for PSC-I vlan = optional(number) # VLAN tag (2-255) # Access Config (External IPv4) access_config = optional(list(object({ nat_ip = optional(string) network_tier = optional(string) # PREMIUM or STANDARD })), []) # IPv6 Access Config (External IPv6) ipv6_access_config = optional(list(object({ network_tier = string # Always PREMIUM for IPv6 })), []) # Alias IP Ranges (Secondary ranges) alias_ip_range = optional(list(object({ ip_cidr_range = string subnetwork_range_name = optional(string) })), []) }))` | `[]` | No |
| `additional_networks_str` | Additional network interface details for GCE provided as a JSON-encoded string. Expected format: '[{\ | `string` | `"[]"` | No |
| `alias_ip_range` | An array of alias IP ranges for this network interface. Can only be specified for network interfaces on subnet-mode networks. ip_cidr_range: The IP CIDR range represented by this alias IP range. This IP CIDR range must belong to the specified subnetwork and cannot contain IP addresses reserved by system or used by other network interfaces. At the time of writing only a netmask (e.g. /24) may be supplied, with a CIDR format resulting in an API error. subnetwork_range_name: The subnetwork secondary range name specifying the secondary range from which to allocate the IP CIDR range for this alias IP range. If left unspecified, the primary range of the subnetwork will be used. | `object({ ip_cidr_range = string subnetwork_range_name = string })` | `null` | No |
| `auto_delete` | Whether or not the boot disk should be auto-deleted | `string` | `"true"` | No |
| `automatic_restart` | (Optional) Specifies whether the instance should be automatically restarted if it is terminated by Compute Engine (not terminated by a user). | `bool` | `true` | No |
| `can_ip_forward` | Enable IP forwarding, for NAT instances for example | `string` | `"false"` | No |
| `confidential_instance_type` | Defines the confidential computing technology the instance uses. If this is set to \ | `string` | `null` | No |
| `create_service_account` | Create a new service account to attach to the instance. This is alternate to providing the service_account input variable. Please provide the service_account input if setting this to false. | `bool` | `true` | No |
| `description` | The template's description | `string` | `""` | No |
| `disk_encryption_key` | The id of the encryption key that is stored in Google Cloud KMS to use to encrypt all the disks on this instance | `string` | `null` | No |
| `disk_labels` | Labels to be assigned to boot disk, provided as a map | `map(string)` | `{}` | No |
| `disk_resource_policies` | A list (short name or id) of resource policies to attach to this disk for automatic snapshot creations | `list(string)` | `[]` | No |
| `disk_size_gb` | Boot disk size in GB | `string` | `"100"` | No |
| `disk_type` | Boot disk type, can be either pd-ssd, local-ssd, or pd-standard | `string` | `"pd-standard"` | No |
| `enable_confidential_vm` | Whether to enable the Confidential VM configuration on the instance. Note that the instance image must support Confidential VMs. See https://cloud.google.com/compute/docs/images | `bool` | `false` | No |
| `enable_nested_virtualization` | Defines whether the instance should have nested virtualization enabled. | `bool` | `false` | No |
| `enable_shielded_vm` | Whether to enable the Shielded VM configuration on the instance. Note that the instance image must support Shielded VMs. See https://cloud.google.com/compute/docs/images | `bool` | `false` | No |
| `gpu` | GPU information. Type and count of GPU to attach to the instance template. See https://cloud.google.com/compute/docs/gpus more details | `object({ type = string count = number })` | `null` | No |
| `instance_description` | Description of the generated instances | `string` | `""` | No |
| `ipv6_access_config` | IPv6 access configurations. Currently a max of 1 IPv6 access configuration is supported. If not specified, the instance will have no external IPv6 Internet access. | `list(object({ network_tier = string }))` | `[]` | No |
| `labels` | Labels, provided as a map | `map(string)` | `{}` | No |
| `machine_type` | Machine type to create, e.g. n1-standard-1 | `string` | `"n1-standard-1"` | No |
| `maintenance_interval` | Specifies the frequency of planned maintenance events | `string` | `null` | No |
| `metadata` | Metadata, provided as a map | `map(string)` | `{}` | No |
| `min_cpu_platform` | Specifies a minimum CPU platform. Applicable values are the friendly names of CPU platforms, such as Intel Haswell or Intel Skylake. See the complete list: https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform | `string` | `null` | No |
| `name_prefix` | Name prefix for the instance template | `string` | `"default-instance-template"` | No |
| `network` | The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks. | `string` | `""` | No |
| `network_attachment` | The self_link of the network attachment for PSC-I connection. | `string` | `null` | No |
| `network_ip` | Private IP address to assign to the instance if desired. | `string` | `""` | No |
| `nic_type` | Valid values are \ | `string` | `null` | No |
| `on_host_maintenance` | Instance availability Policy | `string` | `"MIGRATE"` | No |
| `preemptible` | Allow the instance to be preempted | `bool` | `false` | No |
| `resource_manager_tags` | (Optional) A set of key/value resource manager tag pairs to bind to the instances. Keys must be in the format tagKeys/{tag_key_id}, and values are in the format tagValues/456 | `map(string)` | `null` | No |
| `resource_policies` | A list of self_links of resource policies to attach to the instance. Modifying this list will cause the instance to recreate. Currently a max of 1 resource policy is supported. | `list(string)` | `[]` | No |
| `service_account` | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account. | `object({ email = string scopes = optional(set(string), ["cloud-platform"]) })` | `null` | No |
| `service_account_project_roles` | Roles to grant to the newly created cloud run SA in specified project. Should be used with create_service_account set to true and no input for service_account | `list(string)` | `[]` | No |
| `shielded_instance_config` | Not used unless enable_shielded_vm is true. Shielded VM configuration for the instance. | `object({ enable_secure_boot = bool enable_vtpm = bool enable_integrity_monitoring = bool })` | `{ enable_secure_boot = true enable_vtpm = true enable_integrity_monitoring = true }` | No |
| `source_image` | Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public Rocky Linux 9 optimized for GCP image. | `string` | `""` | No |
| `source_image_family` | Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Rocky Linux 9 optimized for GCP image. | `string` | `"rocky-linux-9-optimized-gcp"` | No |
| `source_image_project` | Project where the source image comes from. The default project contains Rocky Linux images. | `string` | `"rocky-linux-cloud"` | No |
| `spot` | Provision a SPOT instance | `bool` | `false` | No |
| `spot_instance_termination_action` | Action to take when Compute Engine preempts a Spot VM. | `string` | `"STOP"` | No |
| `stack_type` | The stack type for this network interface to identify whether the IPv6 feature is enabled or not. Values are `IPV4_IPV6` or `IPV4_ONLY`. Default behavior is equivalent to IPV4_ONLY. | `string` | `null` | No |
| `startup_script` | User startup script to run when instances spin up | `string` | `""` | No |
| `subnets` | Optional: A map containing subnet details Used to derive the subnetwork URI if subnetwork is not provided. | `list(object({ id = string region = string purpose = string }))` | `[]` | No |
| `subnetwork` | The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided. | `string` | `""` | No |
| `subnetwork_project` | The ID of the project in which the subnetwork belongs. If it is not provided, the provider project is used. | `string` | `""` | No |
| `tags` | Network tags, provided as a list | `list(string)` | `[]` | No |
| `threads_per_core` | The number of threads per physical core. To disable simultaneous multithreading (SMT) set this to 1. | `number` | `null` | No |
| `total_egress_bandwidth_tier` | Egress bandwidth tier setting for supported VM families | `string` | `"DEFAULT"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `name` | Name of instance template |
| `network_interface_details` | The names of the template interfaces. |
| `self_link` | Self-link of instance template |
| `self_link_unique` | Unique self-link of instance template (recommended output to use instead of self_link) |
| `service_account_info` | Service account id and email |
| `tags` | Tags that will be associated with instance(s) |
