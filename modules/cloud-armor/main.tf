resource "google_compute_security_policy" "policy" {
  name        = var.policy_name
  description = "Cloud Armor security policy for source IP allowlisting"
  project     = var.project_id

  # Rule 1: Allow whitelisted IP ranges (e.g., Akamai WAF CIDR Blocks)
  rule {
    action   = "allow"
    priority = "100"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.allowed_ip_ranges
      }
    }
    description = "Allow traffic from configured source IP ranges."
  }

  # Rule 2: Default Deny (Drop all other untrusted direct internet bypass attempts)
  rule {
    action   = "deny(403)"
    priority = "2147483647" # Default lowest priority rule
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Deny all traffic not matching the configured allowlist."
  }
}