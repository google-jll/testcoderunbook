# GCP Terraform Module: Cloud KMS

This module provisions and manages **Cloud KMS** (Key Management Service) infrastructure on Google Cloud Platform following enterprise foundation standards. It creates KMS Key Rings, symmetric and asymmetric Crypto Keys, rotation policies, and non-authoritative (additive) IAM member bindings for service accounts and workloads.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_kms_key_ring`** (1 instance): `keyring`
- **`google_kms_crypto_key`** (1+ instances): `keys`
- **`google_kms_crypto_key_iam_member`** (dynamic instances): `key_iam_members`
- **`google_kms_key_ring_iam_member`** (dynamic instances): `keyring_iam_members`

## Usage Examples

### 1. Basic Key Ring with Symmetric Keys

```hcl
module "kms" {
  source = "../../modules/cloud-kms"

  project_id = "my-project-id"
  location   = "us-central1"
  keyring    = "app-keyring"

  # Simple symmetric keys with 90-day automatic rotation
  key_names = [
    "storage-key",
    "compute-key",
    "database-key",
  ]
}
```

### 2. Comprehensive Multi-Key Architecture with CMEK Grants

```hcl
module "kms" {
  source = "../../modules/cloud-kms"

  project_id = "my-project-id"
  location   = "us-central1"
  keyring    = "central-security-keyring"

  labels = {
    environment = "production"
    compliance  = "pci-dss"
  }

  keys = {
    "gcs-storage-cmek" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s" # 90 days
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }
    "secret-manager-cmek" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "2592000s" # 30 days
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }
    "asymmetric-signing-key" = {
      purpose = "ASYMMETRIC_SIGN"
      version_template = {
        algorithm        = "RSA_SIGN_PSS_2048_SHA256"
        protection_level = "SOFTWARE"
      }
    }
  }

  # Additive IAM encrypter/decrypter role bindings for Google service agents
  encrypters_decrypters = {
    "gcs-storage-cmek" = [
      "serviceAccount:service-123456789012@gs-project-accounts.iam.gserviceaccount.com",
    ]
    "secret-manager-cmek" = [
      "serviceAccount:service-123456789012@gcp-sa-secretmanager.iam.gserviceaccount.com",
    ]
  }

  viewers = {
    "asymmetric-signing-key" = [
      "group:security-auditors@example.com",
    ]
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
| `keyring` | The short name of the Cloud KMS Key Ring. | `string` | n/a | Yes |
| `location` | The location for the KeyRing (e.g. 'global', 'us-central1', 'europe-west1'). | `string` | n/a | Yes |
| `project_id` | The ID of the project in which to provision Cloud KMS resources. | `string` | n/a | Yes |
| `admins` | Map of crypto key names to list of IAM members granted roles/cloudkms.admin. | `map(list(string))` | `{}` | No |
| `decrypters` | Map of crypto key names to list of IAM members granted roles/cloudkms.cryptoKeyDecrypter. | `map(list(string))` | `{}` | No |
| `encrypters` | Map of crypto key names to list of IAM members granted roles/cloudkms.cryptoKeyEncrypter. | `map(list(string))` | `{}` | No |
| `encrypters_decrypters` | Map of crypto key names to list of IAM members granted roles/cloudkms.cryptoKeyEncrypterDecrypter. | `map(list(string))` | `{}` | No |
| `key_iam_members` | Map of crypto key names to a map of IAM roles and list of members to bind additively. | `map(map(list(string)))` | `{}` | No |
| `key_names` | List of simple symmetric crypto key names to create with default symmetric encryption and rotation. | `list(string)` | `[]` | No |
| `key_ring_iam_members` | Map of IAM roles to list of members to bind additively at the KeyRing level. | `map(list(string))` | `{}` | No |
| `keys` | Map of crypto keys to create with granular settings (purpose, rotation_period, destroy_scheduled_duration, labels, version_template). | `map(object({ purpose = optional(string, "ENCRYPT_DECRYPT") rotation_period = optional(string, "7776000s") destroy_scheduled_duration = optional(string, "86400s") import_only = optional(bool, false) labels = optional(map(string), {}) skip_initial_version_creation = optional(bool, false) crypto_key_backend = optional(string, null) version_template = optional(object({ algorithm = string protection_level = optional(string, "SOFTWARE") }), null) }))` | `{}` | No |
| `labels` | Global labels to attach to all crypto keys created by this module. | `map(string)` | `{}` | No |
| `viewers` | Map of crypto key names to list of IAM members granted roles/cloudkms.viewer. | `map(list(string))` | `{}` | No |
## Outputs

| Name | Description |
|------|-------------|
| `key_ids` | Map of crypto key names to their fully-qualified resource IDs. |
| `key_names` | List of crypto key names managed by this module. |
| `keyring` | The created KeyRing resource object. |
| `keyring_id` | The fully-qualified identifier of the created KeyRing. |
| `keyring_location` | The location of the created KeyRing. |
| `keyring_name` | The name of the created KeyRing. |
| `keys` | Map of all created CryptoKey resource objects. |
| `primary_version_ids` | Map of crypto key names to their primary version IDs (where available). |
