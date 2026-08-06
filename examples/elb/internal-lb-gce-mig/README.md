# GCP Terraform Example: Elb - Internal Lb Gce Mig

This example demonstrates how to deploy and manage infrastructure for **Elb - Internal Lb Gce Mig** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.internal-lb-network`**: Source `"terraform-google-modules/network/google//modules/vpc"`
- **`module.internal-lb-subnet`**: Source `"terraform-google-modules/network/google//modules/subnets"`
- **`module.instance-template-region-a`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.instance-template-region-b`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.mig-region-a`**: Source `"../../../modules/compute-vm/mig"`
- **`module.mig-region-b`**: Source `"../../../modules/compute-vm/mig"`
- **`module.internal-lb-http-backend`**: Source `"../../../modules/elb/backend"`
- **`module.internal-lb-http-frontend`**: Source `"../../../modules/elb/frontend"`
- **`module.frontend-service-a`**: Source `"GoogleCloudPlatform/cloud-run/google//modules/v2"`
- **`module.frontend-service-b`**: Source `"GoogleCloudPlatform/cloud-run/google//modules/v2"`

### Resources Provisioned Directly
- `google_vpc_access_connector.internal_lb_vpc_connector`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/elb/internal-lb-gce-mig

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
| `external_cloudrun_uris` | List of URIs for the frontend Cloud Run services |
