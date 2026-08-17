# GCP Terraform Module: Nsi Producer

This module provisions and manages **Nsi Producer** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_forwarding_rule`** (1 instance): `main`
- **`google_compute_instance_template`** (1 instance): `main`
- **`google_compute_region_autoscaler`** (1 instance): `main`
- **`google_compute_region_backend_service`** (1 instance): `main`
- **`google_compute_region_health_check`** (1 instance): `main`
- **`google_compute_region_instance_group_manager`** (1 instance): `main`
- **`google_network_security_intercept_deployment`** (1 instance): `main`
- **`google_network_security_intercept_deployment_group`** (1 instance): `main`
- **`google_network_security_mirroring_deployment`** (1 instance): `main`
- **`google_network_security_mirroring_deployment_group`** (1 instance): `main`
- **`google_project_iam_member`** (1 instance): `main`
- **`google_service_account`** (1 instance): `main`

### Submodules Called
- **`module.bootstrap`**: `source = "./bootstrap"`
- **`module.firewall`**: `source = "../firewall"`

## Usage Example

```hcl
module "nsi_producer" {
  source = "../../modules/nsi-producer"

  project_id = var.project_id
  region = var.region
  data_network_id = var.data_network_id
  data_subnetwork_id = var.data_subnetwork_id
  mgmt_subnetwork_id = var.mgmt_subnetwork_id
  firewall_rules = var.firewall_rules
  # prefix = null
  # untrust_subnetwork_id = null
  # mirroring_deployment = false
}
```

## Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.3` |
| **Google Cloud Provider** | `>= 5.0, < 8` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `data_network_id` | Self link or id of the dataplane VPC network the firewalls and load balancer attach to. | `string` | n/a | Yes |
| `data_subnetwork_id` | Self link or id of the dataplane subnet. | `string` | n/a | Yes |
| `mgmt_subnetwork_id` | Self link or id of the management subnet. | `string` | n/a | Yes |
| `project_id` | GCP Project ID. | `string` | n/a | Yes |
| `region` | GCP region for the load balancer, MIG, and forwarding rules. | `string` | n/a | Yes |
| `bootstrap_bucket_name` | Explicit name for the VM-Series bootstrap bucket. Leave null to auto-generate `paloaltonetworks-firewall-bootstrap-<random>`. Set it to adopt/import an existing bucket without a rename (which would otherwise churn the instance template metadata). | `string` | `null` | No |
| `bootstrap_files` | Map of local bootstrap files (source path relative to this module) to their     destination paths in the bootstrap bucket. The default only uploads the     config bundle vendored under `bootstrap_files/` (init-cfg.txt, bootstrap.xml,     authcodes). The large PAN-OS content-update packages (antivirus/contents/     wildfire) are NOT vendored in this repo because of their size (~220 MB); drop     them into `bootstrap_files/` and add `content/...` entries here to pre-load     them, otherwise the firewall pulls content over the network on first boot. | `map(string)` | `{ "bootstrap_files/init-cfg.txt" = "config/init-cfg.txt" "bootstrap_files/bootstrap.xml" = "config/bootstrap.xml" "bootstrap_files/authcodes" = "license/authcodes" }` | No |
| `csp_authcodes` | (BYOL only) An authcode registered with your CSP account. | `string` | `""` | No |
| `csp_pin_id` | The firewall registration PIN ID for installing the device certificate onto the firewall. | `string` | `""` | No |
| `csp_pin_value` | The firewall registration PIN value for installing the device certificate onto the firewall. | `string` | `""` | No |
| `firewall_rules` | Plain VPC firewall rules to create alongside the producer, keyed by an     arbitrary name. Each entry targets a `network_name` and carries `ingress_rules`     / `egress_rules` in the same shape as the `firewall` module. | `map(object({ network_name = string ingress_rules = optional(list(object({ name = string description = optional(string, null) disabled = optional(bool, null) priority = optional(number, null) destination_ranges = optional(list(string), []) source_ranges = optional(list(string), []) source_tags = optional(list(string)) source_service_accounts = optional(list(string)) target_tags = optional(list(string)) target_service_accounts = optional(list(string)) allow = optional(list(object({ protocol = string ports = optional(list(string)) })), []) deny = optional(list(object({ protocol = string ports = optional(list(string)) })), []) log_config = optional(object({ metadata = string })) })), []) egress_rules = optional(list(object({ name = string description = optional(string, null) disabled = optional(bool, null) priority = optional(number, null) destination_ranges = optional(list(string), []) source_ranges = optional(list(string), []) source_tags = optional(list(string)) source_service_accounts = optional(list(string)) target_tags = optional(list(string)) target_service_accounts = optional(list(string)) allow = optional(list(object({ protocol = string ports = optional(list(string)) })), []) deny = optional(list(object({ protocol = string ports = optional(list(string)) })), []) log_config = optional(object({ metadata = string })) })), []) }))` | `{}` | No |
| `image_name` | Name of the firewall image within the paloaltonetworksgcp-public project. List with: gcloud compute images list --project paloaltonetworksgcp-public --no-standard-images. | `string` | `"vmseries-flex-bundle2-1126"` | No |
| `machine_type` | The machine type for the firewalls (n2 or e2 recommended). | `string` | `"n2-standard-4"` | No |
| `max_firewalls` | The maximum number of firewalls the autoscaler scales up to. | `number` | `1` | No |
| `mgmt_public_ip` | If true, a public IP is set on the management interface. | `bool` | `false` | No |
| `min_firewalls` | The minimum number of firewalls the autoscaler scales down to. | `number` | `1` | No |
| `mirroring_deployment` | If true, a mirroring deployment is created. If false, an intercept deployment is created. | `bool` | `false` | No |
| `prefix` | An optional name to prepend to each created resource. | `string` | `null` | No |
| `roles` | Roles to assign to the firewall's service account. | `set(string)` | `[ "roles/compute.networkViewer", "roles/logging.logWriter", "roles/monitoring.metricWriter", "roles/monitoring.viewer", "roles/viewer", "roles/stackdriver.accounts.viewer", "roles/stackdriver.resourceMetadata.writer", ]` | No |
| `untrust_subnetwork_id` | Optional self link or id of an untrust subnet. When set, a 3rd (untrust) NIC is added to the firewall template; leave null for the default 2-NIC (mgmt + data) template. | `string` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `backend_service` | Id of the regional backend service fronting the firewalls. |
| `firewall_rules` | Map of firewall_rules key to the created firewall module (ingress/egress rule objects). |
| `forwarding_rules` | Map of zone => forwarding rule id. |
| `instance_group_manager` | Id of the firewall regional managed instance group. |
| `intercept_deployment_group_id` | Id of the intercept deployment group (null when mirroring_deployment = true). |
| `mirroring_deployment_group_id` | Id of the mirroring deployment group (null when mirroring_deployment = false). |
| `service_account_email` | Email of the firewall service account. |
