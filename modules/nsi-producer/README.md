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
| `project_id` | GCP Project ID. | `string` | n/a | Yes |
| `region` | GCP region for the load balancer, MIG, and forwarding rules. | `string` | n/a | Yes |
| `prefix` | An optional name to prepend to each created resource. | `string` | `null` | No |
| `data_network_id` | Self link or id of the dataplane VPC network the firewalls and load balancer attach to. | `string` | n/a | Yes |
| `data_subnetwork_id` | Self link or id of the dataplane subnet. | `string` | n/a | Yes |
| `mgmt_subnetwork_id` | Self link or id of the management subnet. | `string` | n/a | Yes |
| `untrust_subnetwork_id` | Optional self link or id of an untrust subnet. When set, a 3rd (untrust) NIC is added to the firewall template; leave null for the default 2-NIC (mgmt + data) template. | `string` | `null` | No |
| `firewall_rules` | n/a | `map(object({` | n/a | Yes |
| `mirroring_deployment` | If true, a mirroring deployment is created. If false, an intercept deployment is created. | `bool` | `false` | No |
| `mgmt_public_ip` | If true, a public IP is set on the management interface. | `bool` | `false` | No |
| `image_name` | Name of the firewall image within the paloaltonetworksgcp-public project. List with: gcloud compute images list --project paloaltonetworksgcp-public --no-standard-images. | `string` | `"vmseries-flex-bundle2-1126"` | No |
| `machine_type` | The machine type for the firewalls (n2 or e2 recommended). | `string` | `"n2-standard-4"` | No |
| `min_firewalls` | The minimum number of firewalls the autoscaler scales down to. | `number` | `1` | No |
| `max_firewalls` | The maximum number of firewalls the autoscaler scales up to. | `number` | `1` | No |
| `csp_authcodes` | (BYOL only) An authcode registered with your CSP account. | `string` | `""` | No |
| `csp_pin_id` | The firewall registration PIN ID for installing the device certificate onto the firewall. | `string` | `""` | No |
| `csp_pin_value` | The firewall registration PIN value for installing the device certificate onto the firewall. | `string` | `""` | No |
| `roles` | Roles to assign to the firewall's service account. | `set(string)` | `[` | No |
| `bootstrap_bucket_name` | Explicit name for the VM-Series bootstrap bucket. Leave null to auto-generate `paloaltonetworks-firewall-bootstrap-<random>`. Set it to adopt/import an existing bucket without a rename (which would otherwise churn the instance template metadata). | `string` | `null` | No |
| `bootstrap_files` | n/a | `map(string)` | `{` | No |

## Outputs

| Name | Description |
|------|-------------|
| `backend_service` | Id of the regional backend service fronting the firewalls. |
| `instance_group_manager` | Id of the firewall regional managed instance group. |
| `service_account_email` | Email of the firewall service account. |
| `forwarding_rules` | Map of zone => forwarding rule id. |
| `intercept_deployment_group_id` | Id of the intercept deployment group (null when mirroring_deployment = true). |
| `mirroring_deployment_group_id` | Id of the mirroring deployment group (null when mirroring_deployment = false). |
| `firewall_rules` | Map of firewall_rules key to the created firewall module (ingress/egress rule objects). |
