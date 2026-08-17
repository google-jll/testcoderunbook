# GCP Terraform Example: Compute Vm - Mig With Percent

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Mig With Percent** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.preemptible_and_regular_instance_templates`**: Source `"terraform-google-modules/vm/google//modules/preemptible_and_regular_instance_templates"`
- **`module.mig_with_percent`**: Source `"terraform-google-modules/vm/google//modules/mig_with_percent"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/mig_with_percent

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
subnetwork = "YOUR_SUBNETWORK"
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
| `region` | The GCP region to create and test resources in | `string` | `"us-central1"` | No |
| `service_account` | Service account email address and scopes | `object({ email = string scopes = set(string) })` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `preemptible_self_link` | Self-link of preemptible instance template |
| `region` | The GCP region to create and test resources in |
| `regular_self_link` | Self-link of regular instance template |
| `self_link` | Self-link of the managed instance group |
