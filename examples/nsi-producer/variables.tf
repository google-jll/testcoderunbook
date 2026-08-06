variable "project_id" {
  description = "The GCP project to deploy the producer into."
  type        = string
}

variable "region" {
  description = "The GCP region for the networks, firewalls, and load balancer."
  type        = string
  default     = "us-central1"
}

variable "mirroring_deployment" {
  description = "If true, create a mirroring deployment; if false, an intercept deployment. Must match the consumer."
  type        = bool
  default     = false
}

variable "csp_pin_id" {
  description = "VM-Series device certificate registration PIN ID (optional for plan)."
  type        = string
  default     = ""
}

variable "csp_pin_value" {
  description = "VM-Series device certificate registration PIN value (optional for plan)."
  type        = string
  default     = ""
}

variable "csp_authcodes" {
  description = "(BYOL) authcode registered with your CSP account (optional for plan)."
  type        = string
  default     = ""
}
