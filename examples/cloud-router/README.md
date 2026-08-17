# GCP Terraform Example: Cloud Router

This example demonstrates how to deploy and manage infrastructure for **Cloud Router** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.vpc`**: Source `"terraform-google-modules/network/google"`
- **`module.cloud_router`**: Source `"../../modules/cloud-router"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/cloud-router

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
| `project_id` | The GCP project ID | `string` | n/a | Yes |
## Outputs

| Name | Description |
|------|-------------|
| `project_id` | Project ID of the router |
| `router_name` | The name of the created router |
| `router_region` | The region of the created router |
