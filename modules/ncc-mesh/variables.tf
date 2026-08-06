variable "project_id" {
  description = "Project ID of the project that holds the network."
  type        = string
}

variable "ncc_hub_name" {
  description = "The Name of the NCC Hub"
  type        = string
}

variable "ncc_hub_description" {
  description = "The description of the NCC Hub"
  type        = string
  default     = null
}

variable "ncc_hub_labels" {
  description = "These labels will be added the NCC hub"
  type        = map(string)
  default     = {}
}

variable "export_psc" {
  description = "Whether Private Service Connect transitivity is enabled for the hub"
  type        = bool
  default     = false
}

variable "auto_accept_projects" {
  description = <<-EOF
    Project IDs (or numbers) whose spokes are automatically accepted into the
    mesh hub's `default` group. When non-empty, the module manages that group to
    set auto-accept. NOTE: a mesh hub's `default` group is auto-created together
    with the hub, so on an existing hub you must import it first, e.g.:
    `terraform import '<addr>.google_network_connectivity_group.default[0]' projects/<project>/locations/global/hubs/<hub>/groups/default`
  EOF
  type        = list(string)
  default     = []
}

variable "vpc_spokes" {
  description = "VPC network that is associated with the spoke. link_producer_vpc_network: Producer VPC network that is peered with vpc network. In a mesh hub all spokes reach each other any-to-any, so no group assignment is needed."
  type = map(object({
    uri                   = string
    exclude_export_ranges = optional(set(string), [])
    include_export_ranges = optional(set(string), [])
    description           = optional(string)
    labels                = optional(map(string))

    link_producer_vpc_network = optional(object({
      network_name          = string
      peering               = string
      include_export_ranges = optional(list(string))
      exclude_export_ranges = optional(list(string))
      description           = optional(string)
      labels                = optional(map(string))
    }))
  }))
  default = {}
}

variable "hybrid_spokes" {
  description = "VLAN attachments and VPN Tunnels that are associated with the spoke. Type must be one of `interconnect` and `vpn`."
  type = map(object({
    location                   = string
    uris                       = set(string)
    site_to_site_data_transfer = optional(bool, false)
    type                       = string
    description                = optional(string)
    labels                     = optional(map(string))
    include_import_ranges      = optional(list(string), [])
  }))
  default = {}
}

variable "router_appliance_spokes" {
  description = "Router appliance instances that are associated with the spoke."
  type = map(object({
    instances = set(object({
      virtual_machine = string
      ip_address      = string
    }))
    location                   = string
    site_to_site_data_transfer = optional(bool, false)
    description                = optional(string)
    labels                     = optional(map(string))
    include_import_ranges      = optional(list(string), [])
  }))
  default = {}
}

variable "spoke_labels" {
  description = "These labels will be added to all NCC spokes"
  type        = map(string)
  default     = {}
}
