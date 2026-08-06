# GCP Terraform Module: Nsi Consumer

This module provisions and manages **Nsi Consumer** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_network_security_intercept_endpoint_group`** (1 instance): `main`
- **`google_network_security_intercept_endpoint_group_association`** (1 instance): `main`
- **`google_network_security_mirroring_endpoint_group`** (1 instance): `main`
- **`google_network_security_mirroring_endpoint_group_association`** (1 instance): `main`
- **`google_network_security_security_profile`** (1 instance): `main`
- **`google_network_security_security_profile_group`** (1 instance): `main`

### Submodules Called
- **`module.firewall_policy`**: `source = "../firewall-policy"`

## Usage Example

```hcl
module "nsi_consumer" {
  source = "../../modules/nsi-consumer"

  project_id = var.project_id
  org_id = var.org_id
  network_id = var.network_id
  producer_dg = var.producer_dg
  # prefix = ""
  # mirroring_deployment = false
  # inspect_ranges = ["0.0.0.0/0"]
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
| `project_id` | The deployment project ID. | `string` | n/a | Yes |
| `org_id` | The GCP organization ID (the security profile/group are org-scoped). | `string` | n/a | Yes |
| `prefix` | A unique string to prepend to each created resource. | `string` | `""` | No |
| `network_id` | Self link or id of the consumer VPC network the firewall policy and endpoint association attach to. Created outside this module. | `string` | n/a | Yes |
| `producer_dg` | The producer's deployment group id (intercept or mirroring, matching mirroring_deployment). | `string` | n/a | Yes |
| `mirroring_deployment` | If true, a mirroring deployment is created. If false, an intercept deployment is created. Must match the producer. | `bool` | `false` | No |
| `inspect_ranges` | IP ranges whose traffic to/from this consumer VPC is steered to the firewall. The firewall-policy INGRESS rule matches src = these ranges, the EGRESS rule matches dest = these ranges (peer network's CIDR, e.g. the other app's subnet). Defaults to all traffic. | `list(string)` | `["0.0.0.0/0"]` | No |

## Outputs

| Name | Description |
|------|-------------|
| `firewall_policy_id` | Id of the consumer network firewall policy. |
| `security_profile_group_id` | Id of the custom security profile group applied by the firewall rules. |
| `intercept_endpoint_group_id` | Id of the intercept endpoint group (null when mirroring_deployment = true). |
| `mirroring_endpoint_group_id` | Id of the mirroring endpoint group (null when mirroring_deployment = false). |
