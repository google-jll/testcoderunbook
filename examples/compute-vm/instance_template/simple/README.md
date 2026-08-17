# GCP Terraform Example: Compute Vm - Instance Template - Simple

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Instance Template - Simple** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"../../../../modules/compute-vm/instance_template"`

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
cd examples/compute-vm/instance_template/simple

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
tags = "YOUR_TAGS"
labels = "YOUR_LABELS"
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
| `labels` | Labels, provided as a map | `map(string)` | n/a | Yes |
| `project_id` | The GCP project to use for integration tests | `string` | n/a | Yes |
| `tags` | Network tags, provided as a list | `list(string)` | n/a | Yes |
| `enable_nested_virtualization` | Defines whether the instance should have nested virtualization enabled. | `bool` | `false` | No |
| `region` | The GCP region to create and test resources in | `string` | `"us-central1"` | No |
| `service_account` | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account. | `object({ email = string scopes = set(string) })` | `null` | No |
| `subnetwork` | The name of the subnetwork create this instance in. | `any` | `""` | No |
| `threads_per_core` | The number of threads per physical core. To disable simultaneous multithreading (SMT) set this to 1. | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `name` | Name of the instance templates |
| `self_link` | Self-link to the instance template |
