variable "project_id" {
  description = "The GCP project ID to deploy resources in."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy regional resources in."
  type        = string
  default     = "me-central2"
}

variable "zone" {
  description = "The GCP zone to deploy Compute Engine VM instances in."
  type        = string
  default     = "me-central2-a"
}

variable "parent" {
  description = "The parent resource where Secure Tags will be created (e.g. 'organizations/123456789012' or 'projects/my-project-id'). If null, defaults to 'projects/<project_id>'."
  type        = string
  default     = null
}

variable "network_name" {
  description = "Name of the VPC network to create."
  type        = string
  default     = "vpc-secure-tags-demo"
}

variable "subnet_cidr" {
  description = "CIDR range for the demo subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "create_tag_bindings" {
  description = "Whether to create tag bindings on the sample Compute Engine VM instances. Requires roles/compute.instanceAdmin.v1 or roles/resourcemanager.tagUser permissions on the project."
  type        = bool
  default     = true
}

variable "security_profile_group" {
  description = "Optional Security Profile Group ID for NSI / Palo Alto intercept or mirroring steering."
  type        = string
  default     = null
}

variable "create_profile_rules" {
  description = "Whether to create default intercept/mirroring rules for security_profile_group. Set to true when security_profile_group is provided."
  type        = bool
  default     = false
}
