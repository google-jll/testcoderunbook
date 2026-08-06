# GCP Terraform Example: Ncc Mesh - Full Mesh

This example demonstrates how to deploy and manage infrastructure for **Ncc Mesh - Full Mesh** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.spoke_a_vpc`**: Source `"../../../modules/network-foundation"`
- **`module.spoke_b_vpc`**: Source `"../../../modules/network-foundation"`
- **`module.spoke_c_vpc`**: Source `"../../../modules/network-foundation"`
- **`module.ncc`**: Source `"../../../modules/ncc-mesh"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/ncc-mesh/full-mesh

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
| `project_id` | The GCP project that holds the hub and spoke networks. | `string` | n/a | Yes |
| `region` | The GCP region for the spoke VPC subnets. | `string` | `"us-central1"` | No |
| `ncc_hub_name` | Name of the NCC hub. | `string` | `"example-mesh-hub"` | No |

## Outputs

| Name | Description |
|------|-------------|
| `hub` | The NCC hub object. |
| `spokes` | All spoke objects, keyed by type/name. |
