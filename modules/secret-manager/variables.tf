variable "project_id" {
  description = "The ID of the GCP project where Secret Manager resources are provisioned."
  type        = string
}

variable "secrets" {
  description = "Map of secrets to create, keyed by secret_id, supporting versions, CMEK encryption, rotation, replication, and IAM grants."
  type = map(object({
    secret_data           = optional(string, null)
    secret_data_base64    = optional(string, null)
    is_secret_data_base64 = optional(bool, null)
    labels                = optional(map(string), {})
    annotations           = optional(map(string), {})
    expire_time           = optional(string, null)
    ttl                   = optional(string, null)
    version_destroy_ttl   = optional(string, null)
    version_aliases       = optional(map(string), {})
    rotation_period       = optional(string, null)
    next_rotation_time    = optional(string, null)
    topics                = optional(list(string), [])
    kms_key_name          = optional(string, null)
    user_managed_replicas = optional(list(object({
      location     = string
      kms_key_name = optional(string, null)
    })), [])
    deletion_policy = optional(string, "DELETE")
    enabled         = optional(bool, true)
    iam_members     = optional(map(list(string)), {})
  }))
  default = {}
}

# --- Convenience variables for single secret provisioning ---

variable "secret_id" {
  description = "Short name of the secret to provision (used when creating a single secret without using the secrets map)."
  type        = string
  default     = null
}

variable "secret_data" {
  description = "Sensitive initial plaintext secret payload for a single secret."
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_data_base64" {
  description = "Sensitive initial base64-encoded secret payload for a single secret."
  type        = string
  default     = null
  sensitive   = true
}

variable "is_secret_data_base64" {
  description = "Set to true if secret_data is base64-encoded and should be decoded by Secret Manager upon ingestion."
  type        = bool
  default     = null
}

variable "labels" {
  description = "Labels to attach to the created secret."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to attach to the created secret."
  type        = map(string)
  default     = {}
}

variable "expire_time" {
  description = "Timestamp in RFC3339 format when the secret will automatically expire."
  type        = string
  default     = null
}

variable "ttl" {
  description = "Time-to-live duration for the secret (e.g. '86400s')."
  type        = string
  default     = null
}

variable "version_destroy_ttl" {
  description = "Duration before destroyed secret versions are permanently removed (e.g. '86400s')."
  type        = string
  default     = null
}

variable "version_aliases" {
  description = "Map of version alias names to version numbers (e.g. {'latest' = '1'})."
  type        = map(string)
  default     = {}
}

variable "rotation_period" {
  description = "Rotation duration for automatic rotation schedule (e.g. '2592000s' for 30 days)."
  type        = string
  default     = null
}

variable "next_rotation_time" {
  description = "RFC3339 timestamp of the next planned rotation time."
  type        = string
  default     = null
}

variable "topics" {
  description = "List of Cloud Pub/Sub topic IDs to notify for secret events (rotation, version creation)."
  type        = list(string)
  default     = []
}

variable "kms_key_name" {
  description = "Resource ID of the Cloud KMS CryptoKey to use for customer-managed encryption (CMEK)."
  type        = string
  default     = null
}

variable "user_managed_replicas" {
  description = "List of locations and optional CMEK keys for user-managed replication."
  type = list(object({
    location     = string
    kms_key_name = optional(string, null)
  }))
  default = []
}

variable "deletion_policy" {
  description = "Policy for destroyed secret versions: 'DELETE', 'DISABLE', or 'ABANDON'."
  type        = string
  default     = "DELETE"
}

variable "accessors" {
  description = "List or map of IAM members granted roles/secretmanager.secretAccessor (e.g. ['serviceAccount:app@proj.iam.gserviceaccount.com'])."
  type        = any
  default     = []
}

variable "iam_members" {
  description = "Map of secret IDs to a nested map of IAM roles and members to bind additively."
  type        = map(map(list(string)))
  default     = {}
}
