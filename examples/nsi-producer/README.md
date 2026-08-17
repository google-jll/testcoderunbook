# GCP Terraform Example: Nsi Producer

This example demonstrates how to deploy and manage infrastructure for **Nsi Producer** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.mgmt_vpc`**: Source `"../../modules/network-foundation"`
- **`module.data_vpc`**: Source `"../../modules/network-foundation"`
- **`module.mgmt_nat`**: Source `"../../modules/cloud-nat"`
- **`module.nsi_producer`**: Source `"../../modules/nsi-producer"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/nsi-producer

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
| `project_id` | The GCP project to deploy the producer into. | `string` | n/a | Yes |
| `csp_authcodes` | (BYOL) authcode registered with your CSP account (optional for plan). | `string` | `""` | No |
| `csp_pin_id` | VM-Series device certificate registration PIN ID (optional for plan). | `string` | `""` | No |
| `csp_pin_value` | VM-Series device certificate registration PIN value (optional for plan). | `string` | `""` | No |
| `mirroring_deployment` | If true, create a mirroring deployment; if false, an intercept deployment. Must match the consumer. | `bool` | `false` | No |
| `region` | The GCP region for the networks, firewalls, and load balancer. | `string` | `"us-central1"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `backend_service` | Id of the regional backend service fronting the firewalls. |
| `deployment_group_id` | The producer's deployment group id. Pass this to the nsi-consumer module/example as producer_dg. |
| `instance_group_manager` | Id of the firewall regional managed instance group. |
