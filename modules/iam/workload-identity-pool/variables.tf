variable "project_id" {
  description = "The GCP project ID where the Workload Identity Pool will be created."
  type        = string
}

variable "pool_id" {
  description = "The ID of the Workload Identity Pool. Must be 1-32 characters long, contain only lowercase letters, numbers, and hyphens."
  type        = string
}

variable "display_name" {
  description = "A display name for the Workload Identity Pool (must be 32 characters or fewer)."
  type        = string
  default     = null

  validation {
    condition     = var.display_name == null ? true : length(var.display_name) <= 32
    error_message = "The Workload Identity Pool display_name must be 32 characters or fewer."
  }
}

variable "description" {
  description = "A description of the Workload Identity Pool."
  type        = string
  default     = null
}

variable "disabled" {
  description = "Whether the Workload Identity Pool is disabled."
  type        = bool
  default     = false
}

variable "workload_identity_pool_providers" {
  description = "Map of Workload Identity Pool Provider configurations. Key is the provider ID."
  type = map(object({
    provider_id         = optional(string)
    display_name        = optional(string)
    description         = optional(string)
    disabled            = optional(bool, false)
    attribute_mapping   = map(string)
    attribute_condition = optional(string)
    oidc = optional(object({
      issuer_uri        = string
      allowed_audiences = optional(list(string))
      jwks_json         = optional(string)
    }))
    aws = optional(object({
      account_id = string
    }))
    saml = optional(object({
      idp_metadata_xml = string
    }))
  }))
  default = {}
}

variable "sa_bindings" {
  description = "Map of Service Account Workload Identity bindings to grant external workloads permission to impersonate GCP Service Accounts. service_account_id can be a plain email address or a full resource URI."
  type = map(object({
    service_account_id           = string
    roles                        = optional(list(string), ["roles/iam.workloadIdentityUser"])
    workload_identity_principals = list(string)
  }))
  default = {}
}
