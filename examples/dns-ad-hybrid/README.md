# GCP Terraform Example: Dns Ad Hybrid

This example demonstrates how to deploy and manage infrastructure for **Dns Ad Hybrid** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.ad_forwarding_zone`**: Source `"../../modules/cloud-dns"`
- **`module.googleapis_private_zone`**: Source `"../../modules/cloud-dns"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/dns-ad-hybrid

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
vpc_network_self_link = "YOUR_VPC_NETWORK_SELF_LINK"
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
| `project_id` | The GCP project ID hosting DNS. | `string` | n/a | Yes |
| `vpc_network_self_link` | The self_link of the consuming VPC network. | `string` | n/a | Yes |
