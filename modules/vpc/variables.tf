variable "project_id" {
  description = "Project ID that holds the network."
  type        = string
}

variable "name" {
  description = "Name of the VPC network."
  type        = string
}

variable "description" {
  description = "Optional description of the network."
  type        = string
  default     = null
}

variable "auto_create_subnetworks" {
  description = "Whether to create a subnet per region automatically. Keep false for a standalone/custom-mode VPC."
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "Network-wide routing mode: REGIONAL or GLOBAL."
  type        = string
  default     = "REGIONAL"
}

variable "mtu" {
  description = "MTU of the network (1300-8896). Null lets the provider use its default (1460)."
  type        = number
  default     = null
}

variable "delete_default_routes_on_create" {
  description = "Delete the default 0.0.0.0/0 internet route when the network is created."
  type        = bool
  default     = false
}

variable "network_firewall_policy_enforcement_order" {
  description = "Order that firewall rules and policies are evaluated: AFTER_CLASSIC_FIREWALL (GCP default) or BEFORE_CLASSIC_FIREWALL."
  type        = string
  default     = "AFTER_CLASSIC_FIREWALL"
}

variable "subnets" {
  description = "Subnets to create in this network, keyed by subnet name."
  type = map(object({
    region                   = string
    ip_cidr_range            = string
    description              = optional(string)
    private_ip_google_access = optional(bool, false)
    purpose                  = optional(string)
    role                     = optional(string)
    stack_type               = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = {}
}
