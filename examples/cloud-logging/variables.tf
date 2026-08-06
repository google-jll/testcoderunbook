variable "project_id" {
  description = "Optional GCP project ID for project-level Cloud Logging resources."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Optional GCP folder ID (e.g. 'folders/123456789' or '123456789') for folder-level log aggregation."
  type        = string
  default     = null
}

variable "disable_default_sink" {
  description = "Whether to disable the default project _Default log sink to force routing logs to custom regional log buckets."
  type        = bool
  default     = false
}

variable "regional_bucket_location" {
  description = "Location for custom regional log bucket (e.g., us-central1, europe-west1)."
  type        = string
  default     = "us-central1"
}

variable "regional_bucket_id" {
  description = "Bucket ID for custom regional log bucket."
  type        = string
  default     = "us-central1-regional-app-logs"
}

variable "audit_dataset_id" {
  description = "Optional BigQuery dataset ID for log sink export destination. Set to null if BigQuery export is not needed."
  type        = string
  default     = null
}

variable "archive_bucket_name" {
  description = "Optional Cloud Storage bucket name for long-term log archiving. Set to null if GCS archiving is not needed."
  type        = string
  default     = null
}
