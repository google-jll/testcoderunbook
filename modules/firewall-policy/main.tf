locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
}

# -------------------------------------------------------------------------------------
# Global Network Firewall Policy
# -------------------------------------------------------------------------------------
resource "google_compute_network_firewall_policy" "main" {
  name        = "${local.prefix}${var.name}"
  project     = var.project_id
  description = var.description != null ? var.description : "Network firewall policy ${var.name}"
}

# -------------------------------------------------------------------------------------
# Custom Dynamic Firewall Policy Rules (Multi-Action, Multi-Target, Secure Tags, etc.)
# -------------------------------------------------------------------------------------
resource "google_compute_network_firewall_policy_rule" "custom_rules" {
  for_each = var.rules

  project         = var.project_id
  firewall_policy = google_compute_network_firewall_policy.main.name
  priority        = each.value.priority
  direction       = try(each.value.direction, "INGRESS")
  action          = each.value.action
  description     = try(each.value.description, null)
  disabled        = try(each.value.disabled, false)
  enable_logging  = try(each.value.enable_logging, false)

  target_service_accounts = try(each.value.target_service_accounts, null)
  security_profile_group  = try(each.value.security_profile_group, null)

  dynamic "target_secure_tags" {
    for_each = try(each.value.target_secure_tags, null) != null ? each.value.target_secure_tags : []
    content {
      name = target_secure_tags.value
    }
  }

  match {
    src_ip_ranges             = try(each.value.match.src_ip_ranges, null)
    dest_ip_ranges            = try(each.value.match.dest_ip_ranges, null)
    src_region_codes          = try(each.value.match.src_region_codes, null)
    dest_region_codes         = try(each.value.match.dest_region_codes, null)
    src_threat_intelligences  = try(each.value.match.src_threat_intelligences, null)
    dest_threat_intelligences = try(each.value.match.dest_threat_intelligences, null)
    src_fqdns                 = try(each.value.match.src_fqdns, null)
    dest_fqdns                = try(each.value.match.dest_fqdns, null)
    src_address_groups        = try(each.value.match.src_address_groups, null)
    dest_address_groups       = try(each.value.match.dest_address_groups, null)

    dynamic "src_secure_tags" {
      for_each = try(each.value.match.src_secure_tags, null) != null ? each.value.match.src_secure_tags : []
      content {
        name = src_secure_tags.value
      }
    }

    dynamic "layer4_configs" {
      for_each = (
        try(length(each.value.match.layer4_configs), 0) > 0 ?
        each.value.match.layer4_configs :
        [{ ip_protocol = "all", ports = null }]
      )
      content {
        ip_protocol = layer4_configs.value.ip_protocol
        ports       = try(layer4_configs.value.ports, null)
      }
    }
  }
}

# -------------------------------------------------------------------------------------
# Intercept rules — apply the security profile group (mirroring_deployment = false).
# -------------------------------------------------------------------------------------
resource "google_compute_network_firewall_policy_rule" "ingress" {
  count                  = var.create_profile_rules && !var.mirroring_deployment ? 1 : 0
  project                = var.project_id
  priority               = var.ingress_priority
  direction              = "INGRESS"
  action                 = "apply_security_profile_group"
  firewall_policy        = google_compute_network_firewall_policy.main.name
  security_profile_group = var.security_profile_group

  match {
    src_ip_ranges  = var.ingress_src_ip_ranges
    dest_ip_ranges = var.ingress_dest_ip_ranges
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "egress" {
  count                  = var.create_profile_rules && !var.mirroring_deployment ? 1 : 0
  project                = var.project_id
  priority               = var.egress_priority
  direction              = "EGRESS"
  action                 = "apply_security_profile_group"
  firewall_policy        = google_compute_network_firewall_policy.main.name
  security_profile_group = var.security_profile_group

  match {
    src_ip_ranges  = var.egress_src_ip_ranges
    dest_ip_ranges = var.egress_dest_ip_ranges
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

# -------------------------------------------------------------------------------------
# Mirroring rules — mirror traffic to the security profile group
# -------------------------------------------------------------------------------------
resource "google_compute_network_firewall_policy_packet_mirroring_rule" "ingress" {
  provider               = google-beta
  count                  = var.create_profile_rules && var.mirroring_deployment ? 1 : 0
  project                = var.project_id
  priority               = var.ingress_priority
  direction              = "INGRESS"
  action                 = "mirror"
  firewall_policy        = google_compute_network_firewall_policy.main.name
  security_profile_group = "//networksecurity.googleapis.com/${var.security_profile_group}"

  match {
    src_ip_ranges  = var.ingress_src_ip_ranges
    dest_ip_ranges = var.ingress_dest_ip_ranges
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_packet_mirroring_rule" "egress" {
  provider               = google-beta
  count                  = var.create_profile_rules && var.mirroring_deployment ? 1 : 0
  project                = var.project_id
  priority               = var.egress_priority
  direction              = "EGRESS"
  action                 = "mirror"
  firewall_policy        = google_compute_network_firewall_policy.main.name
  security_profile_group = "//networksecurity.googleapis.com/${var.security_profile_group}"

  match {
    src_ip_ranges  = var.ingress_src_ip_ranges
    dest_ip_ranges = var.egress_dest_ip_ranges
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

# -------------------------------------------------------------------------------------
# Associate the policy with target VPC network
# -------------------------------------------------------------------------------------
resource "google_compute_network_firewall_policy_association" "main" {
  count             = var.create_association ? 1 : 0
  name              = "${local.prefix}${var.name}-assoc"
  project           = var.project_id
  firewall_policy   = google_compute_network_firewall_policy.main.id
  attachment_target = var.network_id
}
