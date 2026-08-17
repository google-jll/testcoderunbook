# GCP Terraform Example: Cloud Dns

This example demonstrates how to deploy and manage infrastructure for **Cloud Dns** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.private_zone`**: Source `"../../modules/cloud-dns"`
- **`module.public_zone`**: Source `"../../modules/cloud-dns"`
- **`module.forwarding_zone`**: Source `"../../modules/cloud-dns"`
- **`module.peering_zone`**: Source `"../../modules/cloud-dns"`

### Resources Provisioned Directly
- `google_compute_network.main`
- `google_compute_network.peering_target`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/cloud-dns

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
| `project_id` | The GCP project to create the DNS zones and networks in. | `string` | n/a | Yes |
## Outputs

| Name | Description |
|------|-------------|
| `forwarding_zone_name` | Name of the forwarding zone. |
| `peering_zone_name` | Name of the peering zone. |
| `private_zone_name` | Name of the private managed zone. |
| `public_zone_name_servers` | Name servers for the public zone. |
