variable "project_id" {
  description = "The GCP project to enable APIs on."
  type        = string
}

variable "activate_apis" {
  description = "List of APIs to enable on the project."
  type        = list(string)
  default     = []
}

variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed."
  type        = bool
  default     = true
}

variable "disable_dependent_services" {
  description = "Whether dependent services are also disabled on destroy."
  type        = bool
  default     = true
}
