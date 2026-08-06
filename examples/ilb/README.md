# GCP Terraform Example: Ilb

This example demonstrates how to deploy and manage infrastructure for **Ilb** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"../../modules/compute-vm/instance_template"`
- **`module.mig`**: Source `"../../modules/compute-vm/mig"`
- **`module.ilb`**: Source `"../../modules/ilb"`

### Resources Provisioned Directly
- `google_compute_network.vpc`
- `google_compute_subnetwork.subnet`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/ilb

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
| `project_id` | The GCP project to create the resources in. | `string` | n/a | Yes |
| `region` | The GCP region for the network, MIG, and internal load balancer. | `string` | `"us-central1"` | No |

## Outputs

| Name | Description |
|------|-------------|
| `ilb_ip_address` | The internal IP assigned to the load balancer forwarding rule. |
| `forwarding_rule` | The forwarding rule self link. |
