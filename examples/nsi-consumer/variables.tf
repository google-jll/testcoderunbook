variable "project_id" {
  description = "The GCP project to deploy the consumer into."
  type        = string
}

variable "org_id" {
  description = "The GCP organization ID (the security profile/group are org-scoped)."
  type        = string
}

variable "region" {
  description = "The GCP region for the consumer network."
  type        = string
  default     = "us-central1"
}

variable "producer_dg" {
  description = "The producer's deployment group id (the nsi-producer example's `deployment_group_id` output)."
  type        = string
}

variable "mirroring_deployment" {
  description = "If true, wire the mirroring path; if false, the intercept path. Must match the producer."
  type        = bool
  default     = false
}
