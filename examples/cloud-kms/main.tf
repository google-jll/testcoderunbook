/*
 * GCP Cloud KMS Example.
 * Provisions a Cloud KMS Key Ring, symmetric encryption keys with auto-rotation,
 * asymmetric signing key, and IAM encrypter/decrypter bindings for service accounts.
 */

provider "google" {
  project = var.project_id
}

# Application Service Account demonstrating least-privilege IAM grants
resource "google_service_account" "app_sa" {
  project      = var.project_id
  account_id   = "kms-example-app-sa"
  display_name = "KMS Example Application Service Account"
}

module "kms" {
  source = "../../modules/cloud-kms"

  project_id = var.project_id
  location   = var.location
  keyring    = var.keyring

  labels = {
    environment = "example"
    managed_by  = "terraform"
  }

  # Multi-key configuration supporting symmetric encryption and asymmetric signing
  keys = {
    "storage-encryption-key" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s" # 90 days
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }

    "database-encryption-key" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "2592000s" # 30 days
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }

    "jwt-signing-key" = {
      purpose = "ASYMMETRIC_SIGN"
      version_template = {
        algorithm        = "RSA_SIGN_PSS_2048_SHA256"
        protection_level = "SOFTWARE"
      }
    }
  }

  # Additive IAM grants on individual crypto keys
  encrypters_decrypters = {
    "storage-encryption-key"  = [google_service_account.app_sa.member]
    "database-encryption-key" = [google_service_account.app_sa.member]
  }

  viewers = {
    "jwt-signing-key" = [google_service_account.app_sa.member]
  }
}
