# GCP Terraform Example: Compute Vm - Compute Instance

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Compute Instance** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.compute_instance`**: Source `"../../../modules/compute-vm/compute_instance"`
- **`module.disk_snapshots`**: Source `"../../../modules/compute-vm/compute_disk_snapshot"`

### Resources Provisioned Directly
- `google_compute_network.vpc`
- `google_compute_subnetwork.subnet_a`
- `google_compute_subnetwork.subnet_b`
- `google_compute_instance.multi_nic`
- `google_compute_disk.snapshot_demo`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/compute_instance

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
service_account = "YOUR_SERVICE_ACCOUNT"
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
| `project_id` | The GCP project to create the resources in. | `string` | n/a | Yes |
| `region` | The GCP region for the network and instances. | `string` | `"us-central1"` | No |
| `zone` | The GCP zone for the zonal instances and disks. | `string` | `"us-central1-b"` | No |
| `num_instances` | Number of managed instances to create from the template. | `number` | `1` | No |
| `service_account` | Service account to attach to the templated instances. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account. | `object({` | n/a | Yes |
| `nat_ip` | Optional external IP to assign to the managed instances. Null lets GCP assign an ephemeral IP. | `string` | `null` | No |
| `network_tier` | Network tier for the managed instances' external IP. | `string` | `"PREMIUM"` | No |

## Outputs

| Name | Description |
|------|-------------|
| `instance_names` | Names of the managed instances created from the template. |
| `instance_self_links` | Self links of the managed instances. |
| `multi_nic_instance` | Self link of the standalone multi-NIC / next-hop instance. |
| `snapshot_policy` | Name of the snapshot schedule resource policy. |
