/*
 * GCP Secret Manager Example.
 * Demonstrates an enterprise Secret Manager deployment with CMEK encryption
 * (using Cloud KMS module), automated secret rotation, multi-secret provisioning,
 * and IAM secret accessor role assignments.
 */

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# Application Service Account needing read access to secrets
resource "google_service_account" "app_sa" {
  project      = var.project_id
  account_id   = "secret-manager-app-sa"
  display_name = "Secret Manager Application Consumer"
}

# KMS Key Ring & Crypto Key for Customer-Managed Encryption (CMEK)
module "kms" {
  source = "../../modules/cloud-kms"

  project_id = var.project_id
  location   = var.location
  keyring    = var.keyring_name

  keys = {
    "secret-manager-cmek-key" = {
      purpose         = "ENCRYPT_DECRYPT"
      rotation_period = "7776000s" # 90 days
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }
  }

  labels = {
    environment = "example"
    component   = "security"
  }
}

# Secret Manager Google Service Agent for CMEK decryption
resource "google_project_service_identity" "secretmanager_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

# Grant Secret Manager Service Agent CMEK Encrypter/Decrypter permissions on the KMS key
resource "google_kms_crypto_key_iam_member" "sm_cmek_binding" {
  crypto_key_id = module.kms.key_ids["secret-manager-cmek-key"]
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secretmanager_sa.email}"
}

# Pub/Sub Topic for Secret Manager rotation notifications
resource "google_pubsub_topic" "rotation_topic" {
  project = var.project_id
  name    = "secret-rotation-notifications"
}

# Grant Secret Manager Service Agent permission to publish rotation events to the topic
resource "google_pubsub_topic_iam_member" "sm_pubsub_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.rotation_topic.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_project_service_identity.secretmanager_sa.email}"
}

# Enterprise Secret Manager Module Invocation
module "secrets" {
  source = "../../modules/secret-manager"

  project_id = var.project_id

  secrets = {
    "app-database-credentials" = {
      secret_data        = "DatabaseUserAdmin:P@ssw0rdSecure2026!"
      rotation_period    = "7776000s" # 90 days
      next_rotation_time = "2026-11-01T00:00:00Z"
      topics             = [google_pubsub_topic.rotation_topic.id]
      kms_key_name       = module.kms.key_ids["secret-manager-cmek-key"]
      labels = {
        environment = "example"
        workload    = "database"
      }
      iam_members = {
        "roles/secretmanager.secretAccessor" = [
          google_service_account.app_sa.member
        ]
      }
    }

    "payment-gateway-api-key" = {
      secret_data = "live_api_key_sample_secure_token_987654"
      labels = {
        environment = "example"
        workload    = "payments"
      }
      iam_members = {
        "roles/secretmanager.secretAccessor" = [
          google_service_account.app_sa.member
        ]
      }
    }

    "tls-private-certificate" = {
      secret_data_base64 = base64encode("SAMPLE-TLS-PRIVATE-KEY-CONTENT")
      labels = {
        environment = "example"
        type        = "pki"
      }
      user_managed_replicas = [
        { location = "us-central1" },
        { location = "us-east1" }
      ]
      iam_members = {
        "roles/secretmanager.secretAccessor" = [
          google_service_account.app_sa.member
        ]
      }
    }
  }

  depends_on = [google_kms_crypto_key_iam_member.sm_cmek_binding]
}
