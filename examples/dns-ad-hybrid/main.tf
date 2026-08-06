provider "google" {
  project = var.project_id
}

# -------------------------------------------------------------------------------------
# 1. AD-First DNS: Conditional Forwarding Zone
# Forwards queries for "corp.local." to on-premise Active Directory DNS IPs.
# -------------------------------------------------------------------------------------
module "ad_forwarding_zone" {
  source = "../../modules/cloud-dns"

  project_id  = var.project_id
  type        = "forwarding"
  name        = "ad-forwarding-zone"
  domain      = "corp.local."
  description = "Conditional forwarder to on-prem AD DNS"

  private_visibility_config_networks = [var.vpc_network_self_link]
  
  target_name_server_addresses = [
    { ipv4_address = "10.100.1.10", forwarding_path = "default" },
    { ipv4_address = "10.100.1.11", forwarding_path = "default" }
  ]
}

# -------------------------------------------------------------------------------------
# 2. Private Google Access (PGA) / Restricted VIP Target
# Intercepts *.googleapis.com and maps it to Google's Restricted VIP (199.36.153.4/30).
# -------------------------------------------------------------------------------------
module "googleapis_private_zone" {
  source = "../../modules/cloud-dns"

  project_id  = var.project_id
  type        = "private"
  name        = "googleapis-private-zone"
  domain      = "googleapis.com."
  description = "Private zone for Google APIs Restricted VIP"

  private_visibility_config_networks = [var.vpc_network_self_link]

  recordsets = [
    {
      name    = "*"
      type    = "CNAME"
      ttl     = 300
      records = ["restricted.googleapis.com."]
    },
    {
      name    = "restricted"
      type    = "A"
      ttl     = 300
      records = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
    }
  ]
}