variable "project_id" {
  description = "The GCP project to create the firewall policy in."
  type        = string
}

variable "prefix" {
  description = "An optional string to prepend to created resource names."
  type        = string
  default     = ""
}

variable "name" {
  description = "Base name for the network firewall policy (and its association)."
  type        = string
  default     = "consumer-policy"
}

variable "description" {
  description = "An optional description of this network firewall policy."
  type        = string
  default     = null
}

variable "network_id" {
  description = "Self link or id of the VPC network to associate the policy with."
  type        = string
  default     = null
}

variable "create_association" {
  description = "Whether to create the network firewall policy association with the VPC network specified in network_id."
  type        = bool
  default     = true
}

variable "rules" {
  description = "Map of custom network firewall policy rules to create covering various directions, actions, target types, and match filters."
  type        = any
  default     = {}
}

variable "security_profile_group" {
  description = "Id of the security profile group applied (intercept) or mirrored to (mirroring) by legacy intercept/mirroring rules."
  type        = string
  default     = null
}

variable "create_profile_rules" {
  description = "Whether to create intercept/mirroring profile rules for security_profile_group."
  type        = bool
  default     = false
}

variable "mirroring_deployment" {
  description = "If true, create mirroring rules (action = mirror, google-beta). If false, create intercept rules (action = apply_security_profile_group)."
  type        = bool
  default     = false
}

variable "ingress_src_ip_ranges" {
  description = "Source IP ranges matched by the default INGRESS rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_dest_ip_ranges" {
  description = "Destination IP ranges matched by the default INGRESS rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_src_ip_ranges" {
  description = "Source IP ranges matched by the default EGRESS rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_dest_ip_ranges" {
  description = "Destination IP ranges matched by the default EGRESS rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_priority" {
  description = "Priority of the default ingress rule."
  type        = number
  default     = 10
}

variable "egress_priority" {
  description = "Priority of the default egress rule."
  type        = number
  default     = 11
}
