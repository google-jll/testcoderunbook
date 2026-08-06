# GCP Terraform Example: Folders

This example demonstrates how to deploy and manage infrastructure for **Folders** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.folders`**: Source `"../../modules/folders"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/folders

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
parent = "YOUR_PARENT"
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
| `parent` | Resource name of the parent folder or organization, e.g. \ | `string` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `ids` | Map of folder name to folder id. |
| `names` | Map of folder name to display name. |
