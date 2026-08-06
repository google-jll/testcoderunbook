variable "project_id" {
  description = "The GCP project ID where DNS resources will be created."
  type        = string
}

variable "platform_vpc_id" {
  description = "The full resource ID or self_link of the Dedicated AD (Platform) VPC Network."
  type        = string
}

variable "app_spoke_vpc_ids" {
  description = "List of App Spoke VPC IDs/self_links to bind private DNS zones to."
  type        = list(string)
  default     = []
}

# -------------------------------------------------------------------------------------
# Inbound Policy Settings
# -------------------------------------------------------------------------------------
variable "enable_inbound_endpoint" {
  description = "Whether to create an Inbound DNS Endpoint Policy on the Platform VPC for AD conditional forwarders."
  type        = bool
  default     = true
}

variable "inbound_policy_name" {
  description = "Name of the DNS policy for inbound endpoint."
  type        = string
  default     = "dns-inbound-policy"
}

# -------------------------------------------------------------------------------------
# Managed Private DNS Zones
# -------------------------------------------------------------------------------------
variable "private_zones" {
  description = "Map of private DNS zones to create."
  type = map(object({
    dns_name    = string # e.g. "googleapis.com."
    description = optional(string, "Managed by Terraform")
    # Record sets to create inside this zone. `name` is the record FQDN
    # (e.g. "api.gcp.internal.company.com."); when omitted it defaults to the
    # zone's dns_name (the apex).
    records = optional(map(object({
      name    = optional(string)
      type    = string
      ttl     = number
      records = list(string)
    })), {})
  }))
  default = {}
}

# -------------------------------------------------------------------------------------
# Forwarding Zones (Cloud DNS -> On-Prem/AD Forwarding)
# -------------------------------------------------------------------------------------
variable "forwarding_zones" {
  description = "Map of forwarding DNS zones (e.g. forwarding *.corp.company.com to AD DNS IPs)."
  type = map(object({
    dns_name            = string # e.g. "corp.company.com."
    description         = optional(string, "Forwarding to AD DNS")
    target_name_servers = list(string) # AD DNS Server IPs
  }))
  default = {}
}

# -------------------------------------------------------------------------------------
# Google APIs / PSC Pre-configured DNS Setup
# -------------------------------------------------------------------------------------
variable "enable_google_apis_psc_dns" {
  description = "Automatically create private zones for googleapis.com and p.googleapis.com pointing to PSC/PGA VIPs."
  type        = bool
  default     = true
}

variable "google_apis_vips" {
  description = "List of IP addresses for Google APIs (e.g., 199.36.153.4, 199.36.153.5, 199.36.153.6, 199.36.153.7)."
  type        = list(string)
  default = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7"
  ]
}
