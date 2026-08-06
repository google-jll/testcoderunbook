# GCP Terraform Example: Network Foundation

This example demonstrates how to deploy and manage infrastructure for **Network Foundation** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.network_foundation`**: Source `"../../modules/network-foundation"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/network-foundation

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
vpc_name = "YOUR_VPC_NAME"
environment = "YOUR_ENVIRONMENT"
subnet_cidr_dmz = "YOUR_SUBNET_CIDR_DMZ"
subnet_cidr_app = "YOUR_SUBNET_CIDR_APP"
subnet_cidr_data = "YOUR_SUBNET_CIDR_DATA"
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
| `project_id` | The target GCP Project ID. | `string` | n/a | Yes |
| `vpc_name` | The name of the VPC. | `string` | n/a | Yes |
| `environment` | Workload environment lifecycle stage (e.g., dev, uat, prod). | `string` | n/a | Yes |
| `region` | The primary region for deployment. | `string` | `"us-west1"` | No |
| `subnet_cidr_dmz` | CIDR range for the DMZ / Load Balancer Proxy Subnet Tier. | `string` | n/a | Yes |
| `subnet_cidr_app` | CIDR range for the App Instances Subnet Tier. | `string` | n/a | Yes |
| `subnet_cidr_data` | CIDR range for the Data Subnet Tier. | `string` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `deployed_vpc_self_link` | The self-link of the deployed Standalone VPC. |
| `deployed_subnet_dmz_id` | The ID of the deployed DMZ subnet. |
| `deployed_subnet_app_id` | The ID of the deployed App subnet. |
| `deployed_subnet_data_id` | The ID of the deployed Data subnet. |
