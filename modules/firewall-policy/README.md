# Google Cloud Network Firewall Policy Module

This module manages **Google Cloud Network Firewall Policies** (`google_compute_network_firewall_policy`), their rules (`google_compute_network_firewall_policy_rule`), and their associations (`google_compute_network_firewall_policy_association`) with VPC networks.

---

## Features & Supported Use Cases

- **Multiple Target Types**:
  - **Apply to All**: Applies to all workloads across the attached VPC network.
  - **Service Account Target**: Targets VMs running as specific Service Accounts (`target_service_accounts`).
  - **Secure Tag Target**: Targets VMs labeled with specific Resource Manager Tag Values (`target_secure_tags`).
- **Multiple Rule Actions**:
  - `allow`: Permit matched traffic.
  - `deny`: Block matched traffic.
  - `goto_next`: Bypass current rule and continue evaluation to next priority / lower policies.
  - `apply_security_profile_group`: Send traffic to Network Security Integration (NSI) Intrusion Prevention Service (IPS).
- **Traffic Directions**:
  - `INGRESS`: Inbound traffic filtering.
  - `EGRESS`: Outbound traffic filtering.
- **Rich Match Criteria**:
  - Source / Destination IP Ranges (`src_ip_ranges`, `dest_ip_ranges`).
  - Source Secure Tags (`src_secure_tags`) for cryptographically secure inter-workload micro-segmentation.
  - Layer 4 Protocol & Port specifications (`layer4_configs`).
  - Geo-blocking & Threat Intelligence (`src_region_codes`, `src_threat_intelligences`).
  - Fully Qualified Domain Names (`src_fqdns`, `dest_fqdns`).
  - Address Groups (`src_address_groups`, `dest_address_groups`).
- **Security Profile Group Integration**:
  - Full support for Intercept (`apply_security_profile_group`) and Mirroring (`mirror`) deployments.

---

## Usage Example

### Comprehensive Firewall Policy with Different Target Types & Secure Tags

```hcl
module "firewall_policy" {
  source = "../../modules/firewall-policy"

  project_id  = var.project_id
  name        = "corp-network-policy"
  description = "Corporate network firewall policy with microsegmentation"
  network_id  = module.vpc.network_id

  rules = {
    # Usecase 1: "Apply to All" - Allow egress to internal SD-WAN ranges
    "egress-sdwan" = {
      priority    = 1000
      direction   = "EGRESS"
      action      = "allow"
      description = "Apply to All: Allow egress to internal corporate SD-WAN"
      match = {
        dest_ip_ranges = ["10.200.0.0/16"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["80", "443"]
        }]
      }
    }

    # Usecase 2: "Service Account Target" - Workload SA internet egress
    "egress-workload-sa" = {
      priority                = 1010
      direction               = "EGRESS"
      action                  = "allow"
      description             = "Service Account Target: Egress for specific workload SA"
      target_service_accounts = [google_service_account.app_sa.email]
      match = {
        dest_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["443"]
        }]
      }
    }

    # Usecase 3: "Target Secure Tag" - App1 tagged instance internet access
    "egress-app1-tagged" = {
      priority           = 1020
      direction          = "EGRESS"
      action             = "allow"
      description        = "Secure Tag Target: Egress for App1 tagged instances"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"]]
      match = {
        dest_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["443"]
        }]
      }
    }

    # Usecase 4: "Microsegmentation" - Source Tag to Target Tag
    "ingress-app1-to-database" = {
      priority           = 1030
      direction          = "INGRESS"
      action             = "allow"
      description        = "Microsegmentation: Allow App1 tagged VMs to access Database tagged VMs"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["database"]]
      match = {
        src_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"]]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["5432"]
        }]
      }
    }

    # Usecase 5: "Deny Action" - Inter-App Isolation
    "deny-app1-to-app2" = {
      priority           = 1040
      direction          = "INGRESS"
      action             = "deny"
      description        = "Inter-app isolation: Deny App1 from reaching App2 directly"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app2"]]
      match = {
        src_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"]]
        layer4_configs  = [{ ip_protocol = "all" }]
      }
    }

    # Usecase 6: "IAP Admin Ingress" - Bastion / Google Cloud IAP SSH
    "ingress-iap-ssh" = {
      priority           = 1050
      direction          = "INGRESS"
      action             = "allow"
      description        = "Allow SSH from Google Cloud IAP range"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"]]
      match = {
        src_ip_ranges = ["35.235.240.0/20"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["22"]
        }]
      }
    }
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The GCP project to create the firewall policy in. | `string` | n/a | Yes |
| `create_association` | Whether to create the network firewall policy association with the VPC network specified in network_id. | `bool` | `true` | No |
| `create_profile_rules` | Whether to create intercept/mirroring profile rules for security_profile_group. | `bool` | `false` | No |
| `description` | An optional description of this network firewall policy. | `string` | `null` | No |
| `egress_dest_ip_ranges` | Destination IP ranges matched by the default EGRESS rule. | `list(string)` | `["0.0.0.0/0"]` | No |
| `egress_priority` | Priority of the default egress rule. | `number` | `11` | No |
| `egress_src_ip_ranges` | Source IP ranges matched by the default EGRESS rule. | `list(string)` | `["0.0.0.0/0"]` | No |
| `ingress_dest_ip_ranges` | Destination IP ranges matched by the default INGRESS rule. | `list(string)` | `["0.0.0.0/0"]` | No |
| `ingress_priority` | Priority of the default ingress rule. | `number` | `10` | No |
| `ingress_src_ip_ranges` | Source IP ranges matched by the default INGRESS rule. | `list(string)` | `["0.0.0.0/0"]` | No |
| `mirroring_deployment` | If true, create mirroring rules (action = mirror, google-beta). If false, create intercept rules (action = apply_security_profile_group). | `bool` | `false` | No |
| `name` | Base name for the network firewall policy (and its association). | `string` | `"consumer-policy"` | No |
| `network_id` | Self link or id of the VPC network to associate the policy with. | `string` | `null` | No |
| `prefix` | An optional string to prepend to created resource names. | `string` | `""` | No |
| `rules` | Map of custom network firewall policy rules to create covering various directions, actions, target types, and match filters. | `any` | `{}` | No |
| `security_profile_group` | Id of the security profile group applied (intercept) or mirrored to (mirroring) by legacy intercept/mirroring rules. | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `association_id` | The ID of the network firewall policy association (if associated). |
| `id` | The ID of the network firewall policy. |
| `name` | The name of the network firewall policy. |
| `network_firewall_policy_id` | The unique identifier of the network firewall policy. |
| `rule_tuple_count` | Total count of all firewall policy rule tuples. |
| `rules` | Map of created custom firewall policy rules. |
