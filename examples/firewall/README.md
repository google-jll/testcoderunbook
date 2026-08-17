# GCP Terraform Example: Firewall

This example demonstrates how to deploy and manage infrastructure for **Firewall** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.firewall_rules`**: Source `"../../modules/firewall"`

### Resources Provisioned Directly
- `google_compute_network.vpc`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/firewall

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
| `project_id` | The GCP project to create the network and firewall rules in. | `string` | n/a | Yes |
## Outputs

| Name | Description |
|------|-------------|
| `firewall_rules` | The created ingress/egress firewall rule resources. |
