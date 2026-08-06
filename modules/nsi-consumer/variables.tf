variable "project_id" {
  description = "The deployment project ID."
  type        = string
}

variable "org_id" {
  description = "The GCP organization ID (the security profile/group are org-scoped)."
  type        = string
}

variable "prefix" {
  description = "A unique string to prepend to each created resource."
  type        = string
  default     = ""
}

variable "network_id" {
  description = "Self link or id of the consumer VPC network the firewall policy and endpoint association attach to. Created outside this module."
  type        = string
}

variable "producer_dg" {
  description = "The producer's deployment group id (intercept or mirroring, matching mirroring_deployment)."
  type        = string
}

variable "mirroring_deployment" {
  description = "If true, a mirroring deployment is created. If false, an intercept deployment is created. Must match the producer."
  type        = bool
  default     = false
}

variable "inspect_ranges" {
  description = "IP ranges whose traffic to/from this consumer VPC is steered to the firewall. Defaults to all traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "rules" {
  description = "Optional map of custom network firewall policy rules (e.g. targeting secure tags) passed down to the network firewall policy."
  type        = any
  default     = {}
}
