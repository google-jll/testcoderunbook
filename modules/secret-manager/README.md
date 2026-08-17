# GCP Terraform Module: Secret Manager

This module provisions and manages **Google Secret Manager** secrets, versions, customer-managed encryption (CMEK), rotation schedules, and non-authoritative IAM member bindings following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_secret_manager_secret`** (1+ instances): `secrets`
- **`google_secret_manager_secret_version`** (dynamic instances): `versions`
- **`google_secret_manager_secret_iam_member`** (dynamic instances): `members`

## Usage Examples

### 1. Single Secret with Version & Service Account Access

```hcl
module "db_password_secret" {
  source = "../../modules/secret-manager"

  project_id  = "my-project-id"
  secret_id   = "app-database-credentials"
  secret_data = "SuperSecretPassword123!"

  labels = {
    environment = "production"
    application = "order-service"
  }

  accessors = [
    "serviceAccount:order-service-sa@my-project-id.iam.gserviceaccount.com"
  ]
}
```

### 2. Multi-Secret Setup with CMEK Encryption & Rotation Schedules

```hcl
module "enterprise_secrets" {
  source = "../../modules/secret-manager"

  project_id = "my-project-id"

  secrets = {
    "api-oauth-client-secret" = {
      secret_data     = "oauth-super-secret-token"
      rotation_period = "7776000s" # 90 days
      kms_key_name    = "projects/my-project-id/locations/us-central1/keyRings/my-keyring/cryptoKeys/secret-key"
      labels = {
        tier = "backend"
      }
      iam_members = {
        "roles/secretmanager.secretAccessor" = [
          "serviceAccount:api-gateway-sa@my-project-id.iam.gserviceaccount.com"
        ]
      }
    }

    "tls-private-key" = {
      secret_data_base64 = base64encode("-----BEGIN RSA PRIVATE KEY-----...")
      labels = {
        type = "certificate"
      }
      user_managed_replicas = [
        { location = "us-central1" },
        { location = "us-east1" }
      ]
      iam_members = {
        "roles/secretmanager.secretAccessor" = [
          "serviceAccount:ingress-sa@my-project-id.iam.gserviceaccount.com"
        ]
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.3` |
| **Google Cloud Provider** | `>= 5.0, < 8` |
| **Google Beta Provider** | `>= 5.0, < 8` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The ID of the GCP project where Secret Manager resources are provisioned. | `string` | n/a | Yes |
| `accessors` | List or map of IAM members granted roles/secretmanager.secretAccessor (e.g. ['serviceAccount:app@proj.iam.gserviceaccount.com']). | `any` | `[]` | No |
| `annotations` | Annotations to attach to the created secret. | `map(string)` | `{}` | No |
| `deletion_policy` | Policy for destroyed secret versions: 'DELETE', 'DISABLE', or 'ABANDON'. | `string` | `"DELETE"` | No |
| `expire_time` | Timestamp in RFC3339 format when the secret will automatically expire. | `string` | `null` | No |
| `iam_members` | Map of secret IDs to a nested map of IAM roles and members to bind additively. | `map(map(list(string)))` | `{}` | No |
| `is_secret_data_base64` | Set to true if secret_data is base64-encoded and should be decoded by Secret Manager upon ingestion. | `bool` | `null` | No |
| `kms_key_name` | Resource ID of the Cloud KMS CryptoKey to use for customer-managed encryption (CMEK). | `string` | `null` | No |
| `labels` | Labels to attach to the created secret. | `map(string)` | `{}` | No |
| `next_rotation_time` | RFC3339 timestamp of the next planned rotation time. | `string` | `null` | No |
| `rotation_period` | Rotation duration for automatic rotation schedule (e.g. '2592000s' for 30 days). | `string` | `null` | No |
| `secret_data` | Sensitive initial plaintext secret payload for a single secret. | `string` | `null` | No |
| `secret_data_base64` | Sensitive initial base64-encoded secret payload for a single secret. | `string` | `null` | No |
| `secret_id` | Short name of the secret to provision (used when creating a single secret without using the secrets map). | `string` | `null` | No |
| `secrets` | Map of secrets to create, keyed by secret_id, supporting versions, CMEK encryption, rotation, replication, and IAM grants. | `map(object({ secret_data = optional(string, null) secret_data_base64 = optional(string, null) is_secret_data_base64 = optional(bool, null) labels = optional(map(string), {}) annotations = optional(map(string), {}) expire_time = optional(string, null) ttl = optional(string, null) version_destroy_ttl = optional(string, null) version_aliases = optional(map(string), {}) rotation_period = optional(string, null) next_rotation_time = optional(string, null) topics = optional(list(string), []) kms_key_name = optional(string, null) user_managed_replicas = optional(list(object({ location = string kms_key_name = optional(string, null) })), []) deletion_policy = optional(string, "DELETE") enabled = optional(bool, true) iam_members = optional(map(list(string)), {}) }))` | `{}` | No |
| `topics` | List of Cloud Pub/Sub topic IDs to notify for secret events (rotation, version creation). | `list(string)` | `[]` | No |
| `ttl` | Time-to-live duration for the secret (e.g. '86400s'). | `string` | `null` | No |
| `user_managed_replicas` | List of locations and optional CMEK keys for user-managed replication. | `list(object({ location = string kms_key_name = optional(string, null) }))` | `[]` | No |
| `version_aliases` | Map of version alias names to version numbers (e.g. {'latest' = '1'}). | `map(string)` | `{}` | No |
| `version_destroy_ttl` | Duration before destroyed secret versions are permanently removed (e.g. '86400s'). | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `id` | The fully-qualified identifier of the primary secret (for single-secret module usage). |
| `name` | The short name of the primary secret (for single-secret module usage). |
| `secret_ids` | Map of secret names to their fully-qualified resource IDs. |
| `secret_names` | List of secret short names managed by this module. |
| `secret_version_ids` | Map of secret names to their created secret version resource IDs. |
| `secret_version_names` | Map of secret names to their created secret version name/version number. |
| `secret_versions` | Map of all created secret version resource objects. |
| `secrets` | Map of all created Secret Manager secret resource objects. |
| `version_id` | The fully-qualified identifier of the primary secret version (for single-secret module usage). |
