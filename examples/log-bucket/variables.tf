variable "project_id" {
  description = "The GCP project that owns the log bucket and log scope."
  type        = string
}

variable "region" {
  description = "Default provider region."
  type        = string
  default     = "us-west1"
}

variable "bucket_id" {
  description = "Name of the log bucket to create."
  type        = string
  default     = "example-logs"
}

variable "location" {
  description = "Location of the log bucket (\"global\" or a supported region)."
  type        = string
  default     = "global"
}

variable "retention_days" {
  description = "Days to retain log entries in the bucket."
  type        = number
  default     = 30
}

variable "scope_name" {
  description = "Short name of the log scope."
  type        = string
  default     = "example-scope"
}

variable "scope_resource_names" {
  description = "Projects and/or log views the scope spans (e.g. [\"projects/my-project\"])."
  type        = list(string)
  default     = []
}

variable "sink_source_projects" {
  description = "Projects whose logs are routed into the bucket (one sink each). Leave empty to skip sink creation. The filter in main.tf applies to every sink."
  type        = list(string)
  default     = []
}
