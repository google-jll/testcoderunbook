# GCP Terraform Example: Cloud KMS

This example demonstrates how to deploy and manage infrastructure for **Cloud KMS** (Key Management Service) using standard foundation Terraform modules.

## Architecture & Resources Created

- **Cloud KMS Key Ring**: Provisions a regional Key Ring in the target GCP region.
- **Symmetric Crypto Keys**: Creates symmetric keys with automated 90-day and 30-day rotation schedules for storage and database encryption.
- **Asymmetric Signing Key**: Creates an asymmetric RSA-2048 signing key for JWT/token signing workflows.
- **Service Account & IAM**: Provisions an application Service Account and grants least-privilege `roles/cloudkms.cryptoKeyEncrypterDecrypter` and `roles/cloudkms.viewer` roles additively on specific crypto keys.

### Modules Called

- **`module.kms`**: Source `"../../modules/cloud-kms"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with appropriate KMS and IAM admin permissions.
- **Google Cloud APIs**: Ensure Cloud KMS API (`cloudkms.googleapis.com`) is enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/cloud-kms

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id = "YOUR_PROJECT_ID"
location   = "us-central1"
keyring    = "app-security-keyring"
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
| `project_id` | The ID of the GCP project where KMS resources are provisioned. | `string` | n/a | Yes |
| `keyring` | The name of the Cloud KMS Key Ring. | `string` | `"example-keyring"` | No |
| `location` | The region or location for the Cloud KMS Key Ring (e.g. 'us-central1', 'global', 'europe-west1'). | `string` | `"us-central1"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `app_service_account_email` | Email of the application service account granted KMS access. |
| `key_ids` | Map of crypto key names to their fully-qualified resource IDs. |
| `key_names` | List of crypto key names managed by the KMS module. |
| `keyring_id` | The fully-qualified identifier of the provisioned KeyRing. |
| `keyring_name` | The name of the provisioned KeyRing. |
