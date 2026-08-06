# GCP Terraform Example: Compute Vm - Instance Template - Confidential Computing

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Instance Template - Confidential Computing** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"../../../../modules/compute-vm/instance_template"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/instance_template/confidential_computing

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
subnetwork = "YOUR_SUBNETWORK"
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
| `project_id` | The Google Cloud project ID. | `string` | n/a | Yes |
| `region` | The GCP region to create and test resources in. | `string` | `"us-central1"` | No |
| `subnetwork` | The subnetwork selflink to host the compute instances in. | `string` | n/a | Yes |
| `service_account` | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account. | `object({` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `self_link` | Self-link to the instance template. |
| `name` | Name of the instance templates. |
