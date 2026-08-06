# GCP Terraform Example: Cloud Armor

This example demonstrates how to deploy and manage infrastructure for **Cloud Armor** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.cloud_armor_whitelist`**: Source `"../../modules/cloud-armor"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/cloud-armor

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
policy_name = "YOUR_POLICY_NAME"
allowed_ip_ranges = "YOUR_ALLOWED_IP_RANGES"
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
| `project_id` | The target project ID to host the security policy. | `string` | n/a | Yes |
| `policy_name` | The name of the Cloud Armor security policy. | `string` | n/a | Yes |
| `allowed_ip_ranges` | List of whitelisted IP addresses mapped to Akamai WAF envelopes [4]. | `list(string)` | n/a | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `security_policy_id` | The ID of the provisioned Cloud Armor policy. |
| `security_policy_link` | The self-link of the provisioned Cloud Armor policy. |
| `policy_name` | The name of the provisioned Cloud Armor policy. |
