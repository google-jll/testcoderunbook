# GCP Terraform Example: Api Enablement

This example demonstrates how to deploy and manage infrastructure for **Api Enablement** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.api_enablement`**: Source `"../../modules/api-enablement"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/api-enablement

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
| `project_id` | The GCP project to enable APIs on. | `string` | n/a | Yes |
| `activate_apis` | List of APIs to enable on the project. | `list(string)` | `[]` | No |
| `disable_dependent_services` | Whether dependent services are also disabled on destroy. | `bool` | `true` | No |
| `disable_services_on_destroy` | Whether project services will be disabled when the resources are destroyed. | `bool` | `true` | No |
## Outputs

| Name | Description |
|------|-------------|
| `enabled_apis` | The list of enabled APIs. |
| `project_id` | The project the APIs were enabled on. |
