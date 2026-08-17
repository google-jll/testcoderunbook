# GCP Terraform Example: Compute Vm - Mig Stateful

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Mig Stateful** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.mig`**: Source `"../../../modules/compute-vm/mig"`

### Resources Provisioned Directly
- `random_string.suffix`
- `google_compute_network.main`
- `google_compute_subnetwork.main`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/mig_stateful

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
subnetwork = "YOUR_SUBNETWORK"
target_size = "YOUR_TARGET_SIZE"
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
| `subnetwork` | The subnetwork to host the compute instances in | `any` | n/a | Yes |
| `target_size` | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `any` | n/a | Yes |
| `region` | The GCP region to create and test resources in | `string` | `"us-central1"` | No |
| `service_account` | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account. | `object({ email = string scopes = set(string) })` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `region` | The GCP region to create and test resources in |
| `self_link` | Self-link of the managed instance group |
