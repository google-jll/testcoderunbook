# GCP Terraform Example: Nsi Consumer

This example demonstrates how to deploy and manage infrastructure for **Nsi Consumer** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.consumer_vpc`**: Source `"../../modules/network-foundation"`
- **`module.nsi_consumer`**: Source `"../../modules/nsi-consumer"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/nsi-consumer

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
org_id = "YOUR_ORG_ID"
producer_dg = "YOUR_PRODUCER_DG"
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
| `org_id` | The GCP organization ID (the security profile/group are org-scoped). | `string` | n/a | Yes |
| `producer_dg` | The producer's deployment group id (the nsi-producer example's `deployment_group_id` output). | `string` | n/a | Yes |
| `project_id` | The GCP project to deploy the consumer into. | `string` | n/a | Yes |
| `mirroring_deployment` | If true, wire the mirroring path; if false, the intercept path. Must match the producer. | `bool` | `false` | No |
| `region` | The GCP region for the consumer network. | `string` | `"us-central1"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `firewall_policy_id` | Id of the consumer network firewall policy. |
| `security_profile_group_id` | Id of the security profile group applied to the consumer VPC. |
