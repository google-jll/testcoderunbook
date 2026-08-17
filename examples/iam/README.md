# GCP Terraform Example: Iam

This example demonstrates how to deploy and manage infrastructure for **Iam** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.projects_iam`**: Source `"../../modules/iam/projects_iam"`
- **`module.folders_iam`**: Source `"../../modules/iam/folders_iam"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/iam

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
| `folders` | Folder ids to apply the folder-level IAM bindings to, e.g. \ | `list(string)` | `[]` | No |
| `projects` | Project ids to apply the project-level IAM bindings to. | `list(string)` | `[]` | No |
| `viewer_members` | Members granted the viewer roles (e.g. \ | `list(string)` | `[]` | No |
## Outputs

| Name | Description |
|------|-------------|
| `folder_roles` | Roles applied at the folder level. |
| `project_roles` | Roles applied at the project level. |
