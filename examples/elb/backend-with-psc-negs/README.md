# GCP Terraform Example: Elb - Backend With Psc Negs

This example demonstrates how to deploy and manage infrastructure for **Elb - Backend With Psc Negs** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.producer-network`**: Source `"terraform-google-modules/network/google//modules/vpc"`
- **`module.producer-subnet`**: Source `"terraform-google-modules/network/google//modules/subnets"`
- **`module.gce-ilb`**: Source `"GoogleCloudPlatform/lb-internal/google"`
- **`module.psc-neg-network`**: Source `"terraform-google-modules/network/google//modules/vpc"`
- **`module.psc-neg-subnet`**: Source `"terraform-google-modules/network/google//modules/subnets"`
- **`module.lb-backend-psc-neg`**: Source `"../../../modules/elb/backend"`
- **`module.lb-frontend`**: Source `"../../../modules/elb/frontend"`

### Resources Provisioned Directly
- `google_compute_service_attachment.minimal_sa`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/elb/backend-with-psc-negs

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
| `project_id` | n/a | `string` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | Project ID of the service |
| `psc_negs` | Psc Neg created for this load balancer |
