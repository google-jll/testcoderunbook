variable "project_id" {
  description = "GCP Project ID."
  type        = string
}

variable "region" {
  description = "GCP region for the load balancer, MIG, and forwarding rules."
  type        = string
}

variable "prefix" {
  description = "An optional name to prepend to each created resource."
  type        = string
  default     = null
}

# -------------------------------------------------------------------------------------
# Networking inputs. The dataplane/management VPCs and subnets are created OUTSIDE
# this module (e.g. with network-foundation) and passed in here.
# -------------------------------------------------------------------------------------

variable "data_network_id" {
  description = "Self link or id of the dataplane VPC network the firewalls and load balancer attach to."
  type        = string
}

variable "data_subnetwork_id" {
  description = "Self link or id of the dataplane subnet."
  type        = string
}

variable "mgmt_subnetwork_id" {
  description = "Self link or id of the management subnet."
  type        = string
}

variable "untrust_subnetwork_id" {
  description = "Optional self link or id of an untrust subnet. When set, a 3rd (untrust) NIC is added to the firewall template; leave null for the default 2-NIC (mgmt + data) template."
  type        = string
  default     = null
}

variable "firewall_rules" {
  description = <<-EOF
    Plain VPC firewall rules to create alongside the producer, keyed by an
    arbitrary name. Each entry targets a `network_name` and carries `ingress_rules`
    / `egress_rules` in the same shape as the `firewall` module.
  EOF
  type = map(object({
    network_name = string
    ingress_rules = optional(list(object({
      name                    = string
      description             = optional(string, null)
      disabled                = optional(bool, null)
      priority                = optional(number, null)
      destination_ranges      = optional(list(string), [])
      source_ranges           = optional(list(string), [])
      source_tags             = optional(list(string))
      source_service_accounts = optional(list(string))
      target_tags             = optional(list(string))
      target_service_accounts = optional(list(string))
      allow = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })), [])
      deny = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })), [])
      log_config = optional(object({ metadata = string }))
    })), [])
    egress_rules = optional(list(object({
      name                    = string
      description             = optional(string, null)
      disabled                = optional(bool, null)
      priority                = optional(number, null)
      destination_ranges      = optional(list(string), [])
      source_ranges           = optional(list(string), [])
      source_tags             = optional(list(string))
      source_service_accounts = optional(list(string))
      target_tags             = optional(list(string))
      target_service_accounts = optional(list(string))
      allow = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })), [])
      deny = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })), [])
      log_config = optional(object({ metadata = string }))
    })), [])
  }))
  default = {}
}

# -------------------------------------------------------------------------------------
# Deployment behaviour.
# -------------------------------------------------------------------------------------

variable "mirroring_deployment" {
  description = "If true, a mirroring deployment is created. If false, an intercept deployment is created."
  type        = bool
  default     = false
}

variable "mgmt_public_ip" {
  description = "If true, a public IP is set on the management interface."
  type        = bool
  default     = false
}

# -------------------------------------------------------------------------------------
# Firewall (VM-Series) configuration.
# -------------------------------------------------------------------------------------

variable "image_name" {
  description = "Name of the firewall image within the paloaltonetworksgcp-public project. List with: gcloud compute images list --project paloaltonetworksgcp-public --no-standard-images."
  type        = string
  default     = "vmseries-flex-bundle2-1126"
}

variable "machine_type" {
  description = "The machine type for the firewalls (n2 or e2 recommended)."
  type        = string
  default     = "n2-standard-4"
}

variable "min_firewalls" {
  description = "The minimum number of firewalls the autoscaler scales down to."
  type        = number
  default     = 1
}

variable "max_firewalls" {
  description = "The maximum number of firewalls the autoscaler scales up to."
  type        = number
  default     = 1
}

variable "csp_authcodes" {
  description = "(BYOL only) An authcode registered with your CSP account."
  type        = string
  default     = ""
}

variable "csp_pin_id" {
  description = "The firewall registration PIN ID for installing the device certificate onto the firewall."
  type        = string
  default     = ""
}

variable "csp_pin_value" {
  description = "The firewall registration PIN value for installing the device certificate onto the firewall."
  type        = string
  default     = ""
}

variable "roles" {
  description = "Roles to assign to the firewall's service account."
  type        = set(string)
  default = [
    "roles/compute.networkViewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/viewer",
    "roles/stackdriver.accounts.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ]
}

variable "bootstrap_bucket_name" {
  description = "Explicit name for the VM-Series bootstrap bucket. Leave null to auto-generate `paloaltonetworks-firewall-bootstrap-<random>`. Set it to adopt/import an existing bucket without a rename (which would otherwise churn the instance template metadata)."
  type        = string
  default     = null
}

variable "bootstrap_files" {
  description = <<-EOF
    Map of local bootstrap files (source path relative to this module) to their
    destination paths in the bootstrap bucket. The default only uploads the
    config bundle vendored under `bootstrap_files/` (init-cfg.txt, bootstrap.xml,
    authcodes). The large PAN-OS content-update packages (antivirus/contents/
    wildfire) are NOT vendored in this repo because of their size (~220 MB); drop
    them into `bootstrap_files/` and add `content/...` entries here to pre-load
    them, otherwise the firewall pulls content over the network on first boot.
  EOF
  type        = map(string)
  default = {
    "bootstrap_files/init-cfg.txt"  = "config/init-cfg.txt"
    "bootstrap_files/bootstrap.xml" = "config/bootstrap.xml"
    "bootstrap_files/authcodes"     = "license/authcodes"
  }
}
