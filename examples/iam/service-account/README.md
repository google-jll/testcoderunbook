# GCP Terraform Example: Iam - Service Account

This example demonstrates how to deploy and manage infrastructure for **Iam - Service Account** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.sa`**: Source `"../../../modules/iam/service-account"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/iam/service-account

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
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
| `project_id` | The GCP project to create the service account in. | `string` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `email` | The created service account email. |
| `member` | The IAM member string for the service account. |
