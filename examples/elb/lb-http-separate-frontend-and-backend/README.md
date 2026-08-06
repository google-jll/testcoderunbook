# GCP Terraform Example: Elb - Lb Http Separate Frontend And Backend

This example demonstrates how to deploy and manage infrastructure for **Elb - Lb Http Separate Frontend And Backend** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.cloud-nat-group1`**: Source `"../../../modules/cloud-nat"`
- **`module.cloud-nat-group2`**: Source `"../../../modules/cloud-nat"`
- **`module.lb-http-backend`**: Source `"../../../modules/elb/backend"`
- **`module.lb-http-frontend`**: Source `"../../../modules/elb/frontend"`
- **`module.mig1_template`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.mig1`**: Source `"../../../modules/compute-vm/mig"`
- **`module.mig2_template`**: Source `"../../../modules/compute-vm/instance_template"`
- **`module.mig2`**: Source `"../../../modules/compute-vm/mig"`

### Resources Provisioned Directly
- `google_compute_network.default`
- `google_compute_subnetwork.group1`
- `google_compute_router.group1`
- `google_compute_subnetwork.group2`
- `google_compute_router.group2`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/elb/lb-http-separate-frontend-and-backend

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
| `load-balancer-ip` | n/a |
| `load-balancer-ipv6` | The IPv6 address of the load-balancer, if enabled; else \ |
