# GCP Terraform Example: Cloud Nat

This example demonstrates how to deploy and manage infrastructure for **Cloud Nat** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.test-vpc-module`**: Source `"terraform-google-modules/network/google"`
- **`module.cloud-nat`**: Source `"../../modules/cloud-nat"`

### Resources Provisioned Directly
- `google_compute_instance.default`
- `google_project_iam_member.project`
- `google_compute_firewall.rules`
- `google_compute_router.router`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/cloud-nat

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
network = "YOUR_NETWORK"
subnet = "YOUR_SUBNET"
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
| `project_id` | The project ID to deploy to | `string` | n/a | Yes |
| `network` | The VPC network self link | `string` | n/a | Yes |
| `subnet` | The subnet self link | `string` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `name` | The name of the created Cloud NAT instance |
