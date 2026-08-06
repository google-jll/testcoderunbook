locals {
  # Consolidate all VPCs that need visibility to private zones
  all_authorized_vpcs = distinct(compact(concat([var.platform_vpc_id], var.app_spoke_vpc_ids)))

  # Pre-defined Google APIs zones if enabled
  google_apis_zones = var.enable_google_apis_psc_dns ? {
    "googleapis-com" = {
      dns_name    = "googleapis.com."
      description = "Private zone for Google APIs (PGA/PSC)"
      records = {
        "restricted-cname" = {
          name    = "*.googleapis.com."
          type    = "CNAME"
          ttl     = 300
          records = ["restricted.googleapis.com."]
        }
        "restricted-a" = {
          name    = "restricted.googleapis.com."
          type    = "A"
          ttl     = 300
          records = var.google_apis_vips # <--- Passes all 4 IPs to the A record
        }
      }
    }
    "p-googleapis-com" = {
      dns_name    = "p.googleapis.com."
      description = "Private zone for PSC Google APIs"
      records = {
        "psc-cname" = {
          name    = "*.p.googleapis.com."
          type    = "CNAME"
          ttl     = 300
          records = ["entry.p.googleapis.com."]
        }
        "psc-a" = {
          name    = "entry.p.googleapis.com."
          type    = "A"
          ttl     = 300
          records = var.google_apis_vips # <--- Passes all 4 IPs to the A record
        }
      }
    }
  } : {}

  # Combine custom zones and automated Google API zones
  all_private_zones = merge(local.google_apis_zones, var.private_zones)
}

# -------------------------------------------------------------------------------------
# 1. Cloud DNS Inbound Policy (Provides Inbound Endpoint IP for AD DNS)
# -------------------------------------------------------------------------------------
resource "google_dns_policy" "inbound_policy" {
  count                     = var.enable_inbound_endpoint ? 1 : 0
  project                   = var.project_id
  name                      = var.inbound_policy_name
  enable_inbound_forwarding = true
  description               = "Inbound DNS policy allowing Dedicated AD DNS to query Cloud DNS"

  networks {
    network_url = var.platform_vpc_id
  }
}

# Data source to automatically retrieve the dynamically assigned Inbound Endpoint IPs
data "google_netblock_ip_ranges" "dns_inbound_ips" {
  count      = var.enable_inbound_endpoint ? 1 : 0
  range_type = "dns-forwarders"
}

# -------------------------------------------------------------------------------------
# 2. Private DNS Zones
# -------------------------------------------------------------------------------------
resource "google_dns_managed_zone" "private_zone" {
  for_each    = local.all_private_zones
  project     = var.project_id
  name        = each.key
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = local.all_authorized_vpcs
      content {
        network_url = networks.value
      }
    }
  }
}

# -------------------------------------------------------------------------------------
# 3. Dynamic Record Sets inside Private Zones
# -------------------------------------------------------------------------------------
locals {
  # Flatten out the records from map structure for for_each consumption
  dns_records = flatten([
    for zone_key, zone_val in local.all_private_zones : [
      for rec_key, rec_val in try(zone_val.records, {}) : {
        zone_key = zone_key
        rec_key  = rec_key
        name     = try(coalesce(rec_val.name, zone_val.dns_name), zone_val.dns_name)
        type     = rec_val.type
        ttl      = rec_val.ttl
        records  = rec_val.records
      }
    ]
  ])
}

resource "google_dns_record_set" "records" {
  for_each = {
    for r in local.dns_records : "${r.zone_key}-${r.rec_key}" => r
  }

  project      = var.project_id
  managed_zone = google_dns_managed_zone.private_zone[each.value.zone_key].name
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.records
}

# -------------------------------------------------------------------------------------
# 4. Outbound Forwarding Zones (Cloud DNS -> Active Directory DNS)
# -------------------------------------------------------------------------------------
resource "google_dns_managed_zone" "forwarding_zone" {
  for_each    = var.forwarding_zones
  project     = var.project_id
  name        = each.key
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = local.all_authorized_vpcs
      content {
        network_url = networks.value
      }
    }
  }

  forwarding_config {
    dynamic "target_name_servers" {
      for_each = each.value.target_name_servers
      content {
        ipv4_address = target_name_servers.value
      }
    }
  }
}
