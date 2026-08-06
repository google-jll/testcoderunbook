variable "project_id" {
  description = "Project that will own the service account and role bindings."
  type        = string
}

variable "account_id" {
  description = "The account id (the part before @) of the service account, e.g. \"panw-v2-sa\"."
  type        = string
}

variable "display_name" {
  description = "Human-readable display name for the service account."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the service account."
  type        = string
  default     = null
}

variable "project_roles" {
  description = "Project-level IAM roles to grant to this service account (non-authoritative member bindings)."
  type        = list(string)
  default     = []
}
