variable "project_id" {
  description = "Optional. The GCP project ID where project-level Cloud Logging resources will be created."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Optional. The GCP folder ID (e.g. 'folders/123456789' or '123456789') where folder-level Cloud Logging resources will be created."
  type        = string
  default     = null
}

variable "disable_default_sink" {
  description = "Optional. Whether to disable the default project _Default log sink to prevent pushing logs to the global _Default bucket, routing logs exclusively to custom regional log buckets."
  type        = bool
  default     = false
}

variable "log_sinks" {
  description = "Map of Project Log Sinks to export logs to Storage, BigQuery, PubSub, or custom regional Log Buckets."
  type = map(object({
    name                   = string
    destination            = string # e.g. "storage.googleapis.com/my-bucket", "bigquery.googleapis.com/projects/p/datasets/d", "logging.googleapis.com/projects/p/locations/us-central1/buckets/my-regional-bucket"
    filter                 = optional(string)
    description            = optional(string)
    disabled               = optional(bool, false)
    unique_writer_identity = optional(bool, true) # Automatically creates service account writer identity
    custom_writer_identity = optional(string)     # Custom service account identity to write logs
    bigquery_options = optional(object({
      use_partitioned_tables = bool
    }))
    exclusions = optional(list(object({
      name        = string
      description = optional(string)
      filter      = string
      disabled    = optional(bool, false)
    })), [])
  }))
  default = {}
}

variable "log_metrics" {
  description = "Map of Log-based Metrics to extract metrics from logs at the project level."
  type = map(object({
    name            = string
    filter          = string
    description     = optional(string)
    disabled        = optional(bool, false)
    bucket_name     = optional(string)
    value_extractor = optional(string) # Optional regex extractor for distribution metrics
    metric_descriptor = optional(object({
      metric_kind = string # "DELTA", "GAUGE", "CUMULATIVE"
      value_type  = string # "INT64", "DOUBLE", "DISTRIBUTION"
      unit        = optional(string, "1")
    }))
    label_extractors = optional(map(string), {})
    bucket_options = optional(object({
      linear_buckets = optional(object({
        num_finite_buckets = number
        width              = number
        offset             = number
      }))
      exponential_buckets = optional(object({
        num_finite_buckets = number
        growth_factor      = number
        scale              = number
      }))
      explicit_buckets = optional(object({
        bounds = list(number)
      }))
    }))
  }))
  default = {}
}

variable "log_buckets" {
  description = "Map of custom project log bucket configurations (supports global or regional log buckets such as us-central1, europe-west1)."
  type = map(object({
    location         = string # e.g. "global", "us-central1", "europe-west1"
    bucket_id        = string # e.g. "_Default", "regional-app-logs"
    retention_days   = optional(number, 30)
    enable_analytics = optional(bool, false)
    description      = optional(string)
    cmek_settings = optional(object({
      kms_key_name = string
    }))
    index_configs = optional(list(object({
      field_path = string
      type       = optional(string, "INDEX_TYPE_STRING") # "INDEX_TYPE_STRING", "INDEX_TYPE_INTEGER"
    })), [])
  }))
  default = {}
}

variable "log_exclusions" {
  description = "Map of project-level log exclusions to filter out unwanted logs before ingestion."
  type = map(object({
    name        = string
    filter      = string
    description = optional(string)
    disabled    = optional(bool, false)
  }))
  default = {}
}

variable "folder_sinks" {
  description = "Map of Folder Log Sinks to export aggregated logs across all child projects in a folder."
  type = map(object({
    name               = string
    destination        = string
    folder_id          = optional(string) # Optional override if var.folder_id is set globally
    filter             = optional(string)
    description        = optional(string)
    disabled           = optional(bool, false)
    include_children   = optional(bool, true) # Aggregates logs from all child projects in the folder
    intercept_children = optional(bool, false) # Intercepts logs so child project log routers do not process them
    bigquery_options = optional(object({
      use_partitioned_tables = bool
    }))
    exclusions = optional(list(object({
      name        = string
      description = optional(string)
      filter      = string
      disabled    = optional(bool, false)
    })), [])
  }))
  default = {}
}

variable "folder_buckets" {
  description = "Map of Folder Log Bucket configurations."
  type = map(object({
    location       = string
    bucket_id      = string
    folder_id      = optional(string) # Optional override if var.folder_id is set globally
    retention_days = optional(number, 30)
    description    = optional(string)
    cmek_settings = optional(object({
      kms_key_name = string
    }))
    index_configs = optional(list(object({
      field_path = string
      type       = optional(string, "INDEX_TYPE_STRING")
    })), [])
  }))
  default = {}
}

variable "folder_exclusions" {
  description = "Map of Folder-level Log Exclusions to drop logs across all child projects in a folder."
  type = map(object({
    name        = string
    filter      = string
    folder_id   = optional(string) # Optional override if var.folder_id is set globally
    description = optional(string)
    disabled    = optional(bool, false)
  }))
  default = {}
}
