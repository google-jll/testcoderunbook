# Minimal standalone VPC: one network plus an arbitrary set of subnets. Unlike
# network-foundation (opinionated 3-tier naming), this maps 1:1 to whatever a VPC
# actually is, so pre-existing networks/subnets can be imported with no diff.

resource "google_compute_network" "this" {
  project                                   = var.project_id
  name                                      = var.name
  description                               = var.description
  auto_create_subnetworks                   = var.auto_create_subnetworks
  routing_mode                              = var.routing_mode
  mtu                                       = var.mtu
  delete_default_routes_on_create           = var.delete_default_routes_on_create
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
}

resource "google_compute_subnetwork" "this" {
  for_each = var.subnets

  project                  = var.project_id
  name                     = each.key
  region                   = each.value.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.ip_cidr_range
  description              = each.value.description
  private_ip_google_access = each.value.private_ip_google_access
  purpose                  = each.value.purpose
  role                     = each.value.role
  stack_type               = each.value.stack_type

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}
