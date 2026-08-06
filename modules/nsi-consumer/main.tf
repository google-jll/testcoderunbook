locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
}

# -------------------------------------------------------------------------------------
#  mirroring_deployment = false -> intercept endpoint group + association.
# -------------------------------------------------------------------------------------

resource "google_network_security_intercept_endpoint_group" "main" {
  count                       = var.mirroring_deployment ? 0 : 1
  intercept_endpoint_group_id = "${local.prefix}panw-epg"
  location                    = "global"
  intercept_deployment_group  = var.producer_dg
}

resource "google_network_security_intercept_endpoint_group_association" "main" {
  count                                   = var.mirroring_deployment ? 0 : 1
  intercept_endpoint_group_association_id = "${local.prefix}panw-epg-assoc"
  location                                = "global"
  network                                 = var.network_id
  intercept_endpoint_group                = google_network_security_intercept_endpoint_group.main[0].id
}

# -------------------------------------------------------------------------------------
#  mirroring_deployment = true -> mirroring endpoint group + association.
# -------------------------------------------------------------------------------------

resource "google_network_security_mirroring_endpoint_group" "main" {
  count                       = var.mirroring_deployment ? 1 : 0
  mirroring_endpoint_group_id = "${local.prefix}panw-epg"
  location                    = "global"
  mirroring_deployment_group  = var.producer_dg
}

resource "google_network_security_mirroring_endpoint_group_association" "main" {
  count                                   = var.mirroring_deployment ? 1 : 0
  mirroring_endpoint_group_association_id = "${local.prefix}panw-epg-assoc"
  location                                = "global"
  network                                 = var.network_id
  mirroring_endpoint_group                = google_network_security_mirroring_endpoint_group.main[0].id
}

# -------------------------------------------------------------------------------------
#  Custom security profile + profile group.
# -------------------------------------------------------------------------------------

resource "google_network_security_security_profile" "main" {
  name     = "${local.prefix}panw-sp"
  parent   = "organizations/${var.org_id}"
  location = "global"
  type     = var.mirroring_deployment ? "CUSTOM_MIRRORING" : "CUSTOM_INTERCEPT"

  dynamic "custom_intercept_profile" {
    for_each = var.mirroring_deployment ? [] : [1]
    content {
      intercept_endpoint_group = google_network_security_intercept_endpoint_group.main[0].id
    }
  }

  dynamic "custom_mirroring_profile" {
    for_each = var.mirroring_deployment ? [1] : []
    content {
      mirroring_endpoint_group = google_network_security_mirroring_endpoint_group.main[0].id
    }
  }
}

resource "google_network_security_security_profile_group" "main" {
  name                     = "${local.prefix}panw-spg"
  parent                   = "organizations/${var.org_id}"
  location                 = "global"
  custom_intercept_profile = var.mirroring_deployment ? null : google_network_security_security_profile.main.id
  custom_mirroring_profile = var.mirroring_deployment ? google_network_security_security_profile.main.id : null
}

# -------------------------------------------------------------------------------------
#  Network firewall policy + intercept/mirroring rules + association.
#  Delegated to the firewall-policy module.
# -------------------------------------------------------------------------------------

module "firewall_policy" {
  source = "../firewall-policy"

  project_id             = var.project_id
  prefix                 = var.prefix
  name                   = "consumer-policy"
  network_id             = var.network_id
  security_profile_group = google_network_security_security_profile_group.main.id
  create_profile_rules   = true
  mirroring_deployment   = var.mirroring_deployment
  rules                  = var.rules

  # Steer traffic to/from the inspected peer range through the firewall:
  # INGRESS matches src = peer, EGRESS matches dest = peer (other side = anywhere).
  ingress_src_ip_ranges  = var.inspect_ranges
  ingress_dest_ip_ranges = ["0.0.0.0/0"]
  egress_src_ip_ranges   = ["0.0.0.0/0"]
  egress_dest_ip_ranges  = var.inspect_ranges
}
