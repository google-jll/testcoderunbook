# GCP Terraform Example: Compute Vm - Instance Template - Encrypted Disks

This example demonstrates how to deploy and manage infrastructure for **Compute Vm - Instance Template - Encrypted Disks** using standard foundation Terraform modules.

## Architecture & Resources Created

### Modules Called
- **`module.instance_template`**: Source `"../../../../modules/compute-vm/instance_template"`

### Resources Provisioned Directly
- `google_kms_key_ring.keyring`
- `google_kms_crypto_key.example-key`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate IAM permissions on the target GCP project/organization.
- **Google Cloud APIs**: Ensure required Google APIs (e.g. Compute Engine, DNS, IAM, Resource Manager) are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/compute-vm/instance_template/encrypted_disks

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
| `project_id` | The GCP project to use for integration tests | `string` | n/a | Yes |
| `region` | The GCP region to create and test resources in | `string` | `"us-central1"` | No |
| `service_account` | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account. | `object({ email = string scopes = set(string) })` | `null` | No |
| `subnetwork` | The name of the subnetwork create this instance in. | `any` | `""` | No |
## Outputs

| Name | Description |
|------|-------------|
| `name` | Name of the instance templates |
| `self_link` | Self-link to the instance template |
