variable "project_id" {
  description = "The GCP project ID to apply organization policies to."
  type        = string
}

variable "parent" {
  description = "Optional custom parent URI (e.g. 'organizations/1234567890' or 'folders/1234567890'). If omitted, defaults to 'projects/<project_id>'."
  type        = string
  default     = null
}

variable "allowed_regions" {
  description = "List of GCP regional locations permitted by the resource locations policy."
  type        = list(string)
  default     = ["in:us-locations", "in:eu-locations"]
}
