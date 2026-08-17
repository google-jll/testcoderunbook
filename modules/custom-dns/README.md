# Custom Cloud DNS Terraform Module

This module manages **Google Cloud DNS** configurations, including **Inbound Endpoint Policies**, **Private Managed DNS Zones**, **Record Sets**, **Outbound Forwarding Zones (to Active Directory / On-Prem)**, and pre-configured **Google APIs / Private Service Connect (PSC) DNS resolution**.

---

## Features

- **Inbound DNS Endpoint Policy**: Creates a Cloud DNS Inbound Policy (`google_dns_policy`) on the Platform VPC, allowing Active Directory / On-Premise DNS servers to query GCP Private DNS zones.
- **Automated Google APIs & PSC DNS Resolution**: Option (`enable_google_apis_psc_dns = true`) to automatically provision private managed zones for `googleapis.com.` and `p.googleapis.com.` targeting Private Google Access (PGA) / PSC VIPs (`199.36.153.4` - `199.36.153.7`).
- **Private Managed DNS Zones & Records**: Dynamically creates private DNS managed zones (`google_dns_managed_zone`) with associated record sets (`google_dns_record_set`) bound across multiple platform and application spoke VPCs.
- **Outbound Forwarding Zones**: Configures forwarding zones (`google_dns_managed_zone` with `forwarding_config`) to route queries for corporate domains (e.g. `corp.company.com`) to Active Directory domain controllers or on-premise DNS resolvers.

---

## Architecture & Integration

```
 +-----------------------------------------------------------------------------------+
 |                                   GCP Cloud DNS                                   |
 |                                                                                   |
 |  +--------------------------+  +--------------------------+  +-----------------+  |
 |  | Inbound Endpoint Policy  |  |  Private Managed Zones   |  | Outbound Zones  |  |
 |  | (Receives queries from   |  | (googleapis.com, custom) |  | (Forwards to    |  |
 |  |  AD / On-Prem DNS IPs)   |  |                          |  |  On-Prem/AD)    |  |
 |  +--------------------------+  +--------------------------+  +-----------------+  |
 +-----------------------------------------------------------------------------------+
                                         |
                       +-----------------+-----------------+
                       |                                   |
                       v                                   v
          +-------------------------+         +-------------------------+
          |    Platform (AD) VPC    |         |    App Spoke VPCs       |
          +-------------------------+         +-------------------------+
```

---

## Usage Example

```hcl
module "custom_dns" {
  source = "../../modules/custom-dns"

  project_id        = var.project_id
  platform_vpc_id   = module.platform_vpc.network_id
  app_spoke_vpc_ids = [module.spoke_vpc_a.network_id, module.spoke_vpc_b.network_id]

  # Enable Inbound Endpoint for AD DNS conditional forwarders
  enable_inbound_endpoint = true
  inbound_policy_name     = "dns-inbound-policy"

  # Pre-configured Google APIs & PSC DNS resolution
  enable_google_apis_psc_dns = true

  # Custom Managed Private Zones & Records
  private_zones = {
    "internal-app" = {
      dns_name    = "internal.company.com."
      description = "Private zone for internal microservices"
      records = {
        "web-a" = {
          name    = "web.internal.company.com."
          type    = "A"
          ttl     = 300
          records = ["10.10.1.50"]
        }
        "api-cname" = {
          name    = "api.internal.company.com."
          type    = "CNAME"
          ttl     = 300
          records = ["web.internal.company.com."]
        }
      }
    }
  }

  # Outbound Forwarding Zones (Cloud DNS -> Active Directory / On-Prem)
  forwarding_zones = {
    "onprem-corp" = {
      dns_name            = "corp.company.com."
      description         = "Outbound forwarder to corporate AD DNS"
      target_name_servers = ["10.200.1.10", "10.200.1.11"]
    }
  }
}
```

---

## Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.3` |
| **Google Cloud Provider** | `>= 5.0, < 8` |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `platform_vpc_id` | The full resource ID or self_link of the Dedicated AD (Platform) VPC Network. | `string` | n/a | Yes |
| `project_id` | The GCP project ID where DNS resources will be created. | `string` | n/a | Yes |
| `app_spoke_vpc_ids` | List of App Spoke VPC IDs/self_links to bind private DNS zones to. | `list(string)` | `[]` | No |
| `enable_google_apis_psc_dns` | Automatically create private zones for googleapis.com and p.googleapis.com pointing to PSC/PGA VIPs. | `bool` | `true` | No |
| `enable_inbound_endpoint` | Whether to create an Inbound DNS Endpoint Policy on the Platform VPC for AD conditional forwarders. | `bool` | `true` | No |
| `forwarding_zones` | Map of forwarding DNS zones (e.g. forwarding *.corp.company.com to AD DNS IPs). | `map(object({ dns_name = string # e.g. "corp.company.com." description = optional(string, "Forwarding to AD DNS") target_name_servers = list(string) # AD DNS Server IPs }))` | `{}` | No |
| `google_apis_vips` | List of IP addresses for Google APIs (e.g., 199.36.153.4, 199.36.153.5, 199.36.153.6, 199.36.153.7). | `list(string)` | `[ "199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7" ]` | No |
| `inbound_policy_name` | Name of the DNS policy for inbound endpoint. | `string` | `"dns-inbound-policy"` | No |
| `private_zones` | Map of private DNS zones to create. | `map(object({ dns_name = string # e.g. "googleapis.com." description = optional(string, "Managed by Terraform") # Record sets to create inside this zone. `name` is the record FQDN # (e.g. "api.gcp.internal.company.com."); when omitted it defaults to the # zone's dns_name (the apex). records = optional(map(object({ name = optional(string) type = string ttl = number records = list(string) })), {}) }))` | `{}` | No |
## Outputs

| Name | Description |
|------|-------------|
| `forwarding_zone_names` | Map of created forwarding DNS zone names. |
| `inbound_endpoint_entry_guidance` | Guidance on how to find the created Inbound Endpoint IPs for Active Directory configuration. |
| `inbound_policy_id` | The ID of the inbound DNS policy. |
| `private_zone_names` | Map of created private DNS zone names. |
