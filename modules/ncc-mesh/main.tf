locals {
  vpc_spokes = {
    for k, v in google_network_connectivity_spoke.vpc_spoke :
    k => v
  }
  hybrid_spokes = {
    for k, v in google_network_connectivity_spoke.hybrid_spoke :
    k => v
  }
  router_appliance_spokes = {
    for k, v in google_network_connectivity_spoke.router_appliance_spoke :
    k => v
  }
  producer_vpc_network_spoke = {
    for k, v in google_network_connectivity_spoke.producer_vpc_network_spoke :
    k => v
  }
}

# MESH topology hub. Every spoke attached to a mesh hub gets any-to-any
# connectivity with every other spoke through the implicit `default` group —
# there are no center/edge groups as in a star hub.
resource "google_network_connectivity_hub" "hub" {
  name            = var.ncc_hub_name
  project         = var.project_id
  description     = var.ncc_hub_description
  export_psc      = var.export_psc
  labels          = var.ncc_hub_labels
  policy_mode     = "PRESET"
  preset_topology = "MESH"
}

# The mesh hub's implicit `default` group. Managed only when auto_accept_projects
# is set, so spokes from the listed projects are auto-accepted into the mesh.
# NOTE: the auto-created default group stores `hub` as the bare hub name, so use
# `.name` (not `.id`) — passing the full projects/.../hubs/<name> path forces a
# spurious replacement on import.
resource "google_network_connectivity_group" "default" {
  count   = length(var.auto_accept_projects) > 0 ? 1 : 0
  name    = "default"
  hub     = google_network_connectivity_hub.hub.name
  project = var.project_id

  auto_accept {
    auto_accept_projects = var.auto_accept_projects
  }
}

resource "google_network_connectivity_spoke" "vpc_spoke" {
  for_each    = var.vpc_spokes
  project     = split("/", each.value.uri)[1]
  name        = each.key
  location    = "global"
  description = each.value.description
  hub         = google_network_connectivity_hub.hub.id
  labels      = merge(var.spoke_labels, each.value.labels)

  linked_vpc_network {
    uri                   = each.value.uri
    exclude_export_ranges = each.value.exclude_export_ranges
    include_export_ranges = each.value.include_export_ranges
  }
}

resource "google_network_connectivity_spoke" "producer_vpc_network_spoke" {
  for_each    = { for x, y in var.vpc_spokes : x => y.link_producer_vpc_network if y.link_producer_vpc_network != null }
  project     = var.project_id
  name        = "${each.key}-linked-spoke"
  location    = "global"
  description = each.value.description
  hub         = google_network_connectivity_hub.hub.id
  labels      = merge(var.spoke_labels, each.value.labels)

  linked_producer_vpc_network {
    network               = each.value.network_name
    peering               = each.value.peering
    exclude_export_ranges = each.value.exclude_export_ranges
    include_export_ranges = each.value.include_export_ranges
  }
  depends_on = [google_network_connectivity_spoke.vpc_spoke]
}

resource "google_network_connectivity_spoke" "hybrid_spoke" {
  for_each    = var.hybrid_spokes
  project     = var.project_id
  name        = each.key
  location    = each.value.location
  description = each.value.description
  hub         = google_network_connectivity_hub.hub.id
  labels      = merge(var.spoke_labels, each.value.labels)

  dynamic "linked_interconnect_attachments" {
    for_each = each.value.type == "interconnect" ? [1] : []
    content {
      uris                       = each.value.uris
      site_to_site_data_transfer = each.value.site_to_site_data_transfer
      include_import_ranges      = each.value.include_import_ranges
    }
  }

  dynamic "linked_vpn_tunnels" {
    for_each = each.value.type == "vpn" ? [1] : []
    content {
      uris                       = each.value.uris
      site_to_site_data_transfer = each.value.site_to_site_data_transfer
      include_import_ranges      = each.value.include_import_ranges
    }
  }
}

resource "google_network_connectivity_spoke" "router_appliance_spoke" {
  for_each    = var.router_appliance_spokes
  project     = var.project_id
  name        = each.key
  location    = each.value.location
  description = each.value.description
  hub         = google_network_connectivity_hub.hub.id
  labels      = merge(var.spoke_labels, each.value.labels)

  linked_router_appliance_instances {
    dynamic "instances" {
      for_each = each.value.instances
      iterator = instance_list
      content {
        virtual_machine = instance_list.value.virtual_machine
        ip_address      = instance_list.value.ip_address
      }
    }
    site_to_site_data_transfer = each.value.site_to_site_data_transfer
    include_import_ranges      = each.value.include_import_ranges

  }
}
