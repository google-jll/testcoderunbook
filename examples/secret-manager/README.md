# GCP Terraform Example: Secret Manager

This example demonstrates how to deploy and manage infrastructure for **Secret Manager** with customer-managed encryption keys (CMEK) via Cloud KMS, automated rotation schedules, multi-region replication, and application IAM access using standard foundation Terraform modules.

## Architecture & Resources Created

- **Cloud KMS CMEK**: Provisions a Key Ring and symmetric CryptoKey via `modules/cloud-kms` for customer-managed encryption.
- **Service Identity & CMEK IAM**: Creates the Secret Manager Google Service Agent and grants it `roles/cloudkms.cryptoKeyEncrypterDecrypter` on the KMS key.
- **Pub/Sub Rotation Topic**: Provisions Cloud Pub/Sub topic and grants Secret Manager service agent publisher rights for secret rotation notifications.
- **Multi-Secret Provisioning**: Deploys database credentials, API gateway tokens, and TLS private certificate secret versions using `modules/secret-manager`.
- **Automated Rotation**: Configures a 90-day automatic rotation schedule with Pub/Sub notifications for database credentials.
- **Least-Privilege IAM**: Provisions an application Service Account and grants `roles/secretmanager.secretAccessor` additively on specific secrets.

### Modules Called

- **`module.kms`**: Source `"../../modules/cloud-kms"`
- **`module.secrets`**: Source `"../../modules/secret-manager"`

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with Secret Manager and KMS admin privileges.
- **Google Cloud APIs**: Ensure Secret Manager (`secretmanager.googleapis.com`) and Cloud KMS (`cloudkms.googleapis.com`) APIs are enabled in your project.

## Usage & Execution Steps

Follow these steps to deploy the example:

```bash
# 1. Change directory to this example
cd examples/secret-manager

# 2. Create a terraform.tfvars file with required input variables
cat <<EOF > terraform.tfvars
project_id   = "YOUR_PROJECT_ID"
location     = "us-central1"
keyring_name = "secret-manager-keyring"
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
| `project_id` | The ID of the GCP project where Secret Manager resources are provisioned. | `string` | n/a | Yes |
| `keyring_name` | The name of the Cloud KMS Key Ring used for CMEK. | `string` | `"secret-manager-keyring"` | No |
| `location` | The region or location for the Cloud KMS Key Ring (e.g. 'us-central1', 'global'). | `string` | `"us-central1"` | No |
## Outputs

| Name | Description |
|------|-------------|
| `consumer_service_account_email` | Email of the application service account granted secret accessor permission. |
| `kms_key_id` | The KMS CryptoKey ID used for CMEK secret encryption. |
| `secret_ids` | Map of secret names to their fully-qualified resource IDs. |
| `secret_names` | List of secret short names created by the module. |
| `secret_version_ids` | Map of secret names to their created secret version resource IDs. |
