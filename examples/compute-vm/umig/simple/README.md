# GCP Terraform Example: Compute Vm - Umig - Simple

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Umig - Simple** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"terraform-google-modules/vm/google//modules/instance_template"`
- **`module.umig`**: Source `"terraform-google-modules/vm/google//modules/umig"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/umig/simple

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
subnetwork = "YOUR_SUBNETWORK"
num_instances = "YOUR_NUM_INSTANCES"
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
| `num_instances` | Number of instances to create | `any` | n/a | Yes |
| `project_id` | The GCP project to use for integration tests | `string` | n/a | Yes |
| `subnetwork` | The subnetwork to host the compute instances in | `any` | n/a | Yes |
| `region` | The GCP region to create and test resources in | `string` | `"us-central1"` | No |
| `service_account` | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account. | `object({ email = string scopes = set(string) })` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `available_zones` | List of available zones in region |
| `instances_self_links` | List of self-links for compute instances |
| `self_links` | List of self-links of unmanaged instance groups |
