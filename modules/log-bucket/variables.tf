variable "project_id" {
  description = "The GCP project that owns the log bucket (and, if enabled, the log scope)."
  type        = string
}

variable "bucket_id" {
  description = "Name of the log bucket. Use a custom name (e.g. \"jll-network-logs\"), or an existing well-known id (\"_Default\", \"_Required\") to manage that bucket in place."
  type        = string
}

variable "location" {
  description = "Location of the log bucket. \"global\" or a supported region (e.g. \"us-west1\"). Log Analytics is only available in select regions and in \"global\"."
  type        = string
  default     = "global"
}

variable "retention_days" {
  description = "Number of days log entries are retained in the bucket (minimum 1)."
  type        = number
  default     = 30
}

variable "description" {
  description = "An optional description for the log bucket."
  type        = string
  default     = null
}

variable "enable_analytics" {
  description = "Enable Log Analytics (BigQuery-backed SQL querying) on the bucket. WARNING: this is irreversible once enabled."
  type        = bool
  default     = false
}

variable "locked" {
  description = "Lock the bucket so its retention period cannot be reduced. A locked bucket must be emptied before it can be deleted."
  type        = bool
  default     = false
}

variable "deletion_policy" {
  description = "How Terraform handles bucket destruction: \"DELETE\", \"PREVENT\", or \"ABANDON\"."
  type        = string
  default     = "DELETE"

  validation {
    condition     = contains(["DELETE", "PREVENT", "ABANDON"], var.deletion_policy)
    error_message = "The \"deletion_policy\" variable must be one of \"DELETE\", \"PREVENT\", or \"ABANDON\"."
  }
}

variable "kms_key_name" {
  description = "Optional CMEK key resource name to encrypt the bucket (format: projects/<id>/locations/<loc>/keyRings/<ring>/cryptoKeys/<key>). Requires the Cloud Logging service account to have access to the key."
  type        = string
  default     = null
}

variable "index_configs" {
  description = "Optional list of custom field indexes to speed up queries against structured log fields."
  type = list(object({
    field_path = string
    type       = string
  }))
  default = []
}

# ------------------------------------------------------------------------------
# Log Scope — an optional overlay defining the set of projects/views searched
# together in Logs Explorer and Log Analytics.
# ------------------------------------------------------------------------------
variable "create_scope" {
  description = "Whether to create a log scope alongside the bucket."
  type        = bool
  default     = false
}

variable "scope_name" {
  description = "Short name of the log scope (e.g. \"jll-network-scope\"). Required when create_scope is true."
  type        = string
  default     = null
}

variable "scope_resource_names" {
  description = "Resources the log scope spans. Accepts project ids (projects/<id>) and log views (projects/<id>/locations/<loc>/buckets/<bucket>/views/<view>). Max 50 projects / 100 resources."
  type        = list(string)
  default     = []
}

variable "scope_description" {
  description = "An optional description for the log scope."
  type        = string
  default     = null
}

variable "scope_deletion_policy" {
  description = "How Terraform handles log scope destruction: \"DELETE\", \"PREVENT\", or \"ABANDON\"."
  type        = string
  default     = "DELETE"

  validation {
    condition     = contains(["DELETE", "PREVENT", "ABANDON"], var.scope_deletion_policy)
    error_message = "The \"scope_deletion_policy\" variable must be one of \"DELETE\", \"PREVENT\", or \"ABANDON\"."
  }
}

# ------------------------------------------------------------------------------
# Log routing — sinks that feed this bucket. One sink is created in each source
# project (with a unique writer identity), and that identity is granted
# roles/logging.bucketWriter on this bucket's project so it can actually write.
# ------------------------------------------------------------------------------
variable "sink_name" {
  description = "Name of the log sink created in each source project."
  type        = string
  default     = "central-logs-sink"
}

variable "sink_source_projects" {
  description = "Projects whose logs are routed into this bucket. Include this bucket's own project to capture its logs too. The Terraform identity needs logging.sinks permission in every listed project."
  type        = list(string)
  default     = []
}

variable "sink_filter" {
  description = "Advanced logs filter applied to every sink. Null routes all logs."
  type        = string
  default     = null
}
