variable "project_id" {
  description = "The GCP project that owns the DNS resources and the referenced VPCs."
  type        = string
}

variable "region" {
  description = "Default provider region (Cloud DNS itself is global)."
  type        = string
  default     = "us-central1"
}

variable "platform_vpc_name" {
  description = "Name of the existing dedicated AD / platform VPC that hosts the inbound endpoint."
  type        = string
}

variable "app_spoke_vpc_names" {
  description = "Names of existing app-spoke (workload) VPCs to authorize the private/forwarding zones on."
  type        = list(string)
  default     = []
}

# -------------------------------------------------------------------------------------
# Inbound endpoint policy
# -------------------------------------------------------------------------------------
variable "enable_inbound_endpoint" {
  description = "Create an inbound DNS endpoint policy on the platform VPC so on-prem AD can resolve Cloud DNS records."
  type        = bool
  default     = true
}

variable "inbound_policy_name" {
  description = "Name of the inbound DNS policy."
  type        = string
  default     = "dns-inbound-policy"
}

# -------------------------------------------------------------------------------------
# Private Google Access / PSC zones
# -------------------------------------------------------------------------------------
variable "enable_google_apis_psc_dns" {
  description = "Create private zones for googleapis.com and p.googleapis.com pointing at the PGA/PSC VIPs."
  type        = bool
  default     = true
}

variable "google_apis_vips" {
  description = "IP addresses the googleapis.com / p.googleapis.com A records resolve to (restricted VIPs by default)."
  type        = list(string)
  default = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}

# -------------------------------------------------------------------------------------
# Custom private zones and outbound forwarding zones
# -------------------------------------------------------------------------------------
variable "private_zones" {
  description = "Map of custom private DNS zones to create. Each record's `name` is the FQDN; omit it to default to the zone's dns_name (apex)."
  type = map(object({
    dns_name    = string
    description = optional(string, "Managed by Terraform")
    records = optional(map(object({
      name    = optional(string)
      type    = string
      ttl     = number
      records = list(string)
    })), {})
  }))
  default = {}
}

variable "forwarding_zones" {
  description = "Map of outbound forwarding zones (Cloud DNS -> on-prem/AD DNS servers)."
  type = map(object({
    dns_name            = string
    description         = optional(string, "Forwarding to AD DNS")
    target_name_servers = list(string)
  }))
  default = {}
}
