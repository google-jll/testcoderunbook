# GCP Terraform Example: Compute Vm - Umig - Full

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Umig - Full** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"terraform-google-modules/vm/google//modules/instance_template"`
- **`module.umig`**: Source `"terraform-google-modules/vm/google//modules/umig"`

### Resources Provisioned Directly
- `google_compute_address.ip_address`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/umig/full

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
named_ports = "YOUR_NAMED_PORTS"
additional_disks = "YOUR_ADDITIONAL_DISKS"
EOF

# 3. Initialize Terraform plugins and backend
terraform init

# 4. Generate and review execution plan
terraform plan

# 5. Apply infrastructure changes
terraform apply

# 6. Destroy provisioned resources (when finished testing)
terraform destroy
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The GCP project to use for integration tests | `string` | n/a | Yes |
| `hostname` | Hostname prefix for instances. | `string` | `"default"` | No |
| `region` | The GCP region where instances will be deployed. | `string` | `"us-central1"` | No |
| `subnetwork` | Subnet to deploy to. Only one of network or subnetwork should be specified. | `string` | `""` | No |
| `named_ports` | Named name and named port | `list(object({` | n/a | Yes |
| `machine_type` | Machine type to create, e.g. n1-standard-1 | `string` | `"n1-standard-1"` | No |
| `can_ip_forward` | Enable IP forwarding, for NAT instances for example | `string` | `"false"` | No |
| `tags` | Network tags, provided as a list | `list(string)` | `[]` | No |
| `labels` | Labels, provided as a map | `map(string)` | `{` | No |
| `source_image` | Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public Rocky Linux 9 optimized for GCP image. | `string` | `""` | No |
| `source_image_family` | Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Rocky Linux 9 optimized for GCP image. | `string` | `""` | No |
| `source_image_project` | Project where the source image comes from. The default project contains Rocky Linux images. | `string` | `""` | No |
| `disk_size_gb` | Disk size in GB | `string` | `"100"` | No |
| `disk_type` | Disk type, can be either pd-ssd, local-ssd, or pd-standard | `string` | `"pd-standard"` | No |
| `auto_delete` | Whether or not the disk should be auto-deleted | `string` | `"true"` | No |
| `additional_disks` | List of maps of additional disks. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#disk_name | `list(object({` | n/a | Yes |
| `startup_script` | User startup script to run when instances spin up | `string` | `""` | No |
| `metadata` | Metadata, provided as a map | `map(string)` | `{` | No |
| `service_account` | n/a | `object({` | `null` | No |
| `target_size` | The target number of running instances for this managed or unmanaged instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `string` | `1` | No |
| `static_ips` | List of static IPs for VM instances. | `list(string)` | `[]` | No |

## Outputs

| Name | Description |
|------|-------------|
| `instance_template_self_link` | Self-link of instance template |
| `umig_self_links` | List of self-links for unmanaged instance groups |
