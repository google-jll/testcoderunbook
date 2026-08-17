# GCP Terraform Example: Workload Identity Pool

This example demonstrates how to deploy and manage a **Google Cloud Workload Identity Pool** and **Workload Identity Provider** for GitHub Actions keyless CI/CD authentication using the [`workload-identity-pool`](../../../modules/iam/workload-identity-pool) module.

## Architecture & Resources Created

### Modules Called
- **`module.workload_identity_pool`**: Source `"../../../modules/iam/workload-identity-pool"`

### Infrastructure Provisioned
- A **Workload Identity Pool** (`var.pool_id`) in Google Cloud IAM.
- An **OIDC Workload Identity Provider** configured for GitHub Actions (`https://token.actions.githubusercontent.com`).
- An **IAM Member Binding** (`roles/iam.workloadIdentityUser`) on the target Service Account (`var.service_account_id`) allowing workflows in `var.github_repo` to exchange GitHub OIDC tokens for short-lived GCP Google Cloud credentials.

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with IAM permissions to manage Workload Identity Pools (`roles/iam.workloadIdentityPoolAdmin` or `roles/resourcemanager.organizationAdmin`).
- **Google Cloud APIs**: Ensure `iam.googleapis.com` and `sts.googleapis.com` are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/iam/workload-identity-pool

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id         = "YOUR_PROJECT_ID"
pool_id            = "github-actions-pool"
github_repo        = "my-org/my-repo"
service_account_id = "deployer-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com"
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
| `project_id` | The GCP project ID to deploy the Workload Identity Pool into. | `string` | n/a | Yes |
| `create_service_account` | Whether to create a demo Service Account to bind Workload Identity permissions to. | `bool` | `true` | No |
| `github_repo` | The GitHub repository in owner/repo format for attribute mapping and IAM binding (e.g. 'my-org/my-repo'). | `string` | `"my-org/my-repo"` | No |
| `pool_id` | The ID of the Workload Identity Pool. | `string` | `"example-github-pool"` | No |
| `service_account_id` | The Service Account ID (e.g. 'github-deployer-sa') to create if create_service_account=true, or an existing service account email if create_service_account=false. | `string` | `"github-deployer-sa"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `pool_id` | The Workload Identity Pool ID. |
| `pool_name` | The full resource name of the Workload Identity Pool. |
| `provider_names` | Map of full resource names of the Workload Identity Pool Providers. |
| `service_account_email` | The service account email configured for Workload Identity impersonation. |
