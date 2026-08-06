# GCP Terraform Module: Cloud Dns

This module provisions and manages **Cloud Dns** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_dns_managed_zone`** (6 instances): `peering`, `forwarding`, `private`, `public`, `reverse_lookup`, `service_directory`
- **`google_dns_managed_zone_iam_binding`** (1 instance): `managed_zone_iam_binding`
- **`google_dns_managed_zone_iam_member`** (1 instance): `managed_zone_iam_member`
- **`google_dns_managed_zone_iam_policy`** (1 instance): `managed_zone_iam_policy`
- **`google_dns_record_set`** (1 instance): `cloud-static-records`

## Usage Example

```hcl
module "cloud_dns" {
  source = "../../modules/cloud-dns"

  domain = var.domain
  name = var.name
  project_id = var.project_id
  recordsets = var.recordsets
  # private_visibility_config_networks = []
  # gke_clusters_list = []
  # target_name_server_addresses = []
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
| `domain` | Zone domain, must end with a period. | `string` | n/a | Yes |
| `name` | Zone name, must be unique within the project. | `string` | n/a | Yes |
| `private_visibility_config_networks` | List of VPC self links that can see this zone. | `list(string)` | `[]` | No |
| `gke_clusters_list` | The list of Google Kubernetes Engine clusters that can see this zone. | `list(string)` | `[]` | No |
| `project_id` | Project id for the zone. | `string` | n/a | Yes |
| `target_name_server_addresses` | List of target name servers for forwarding zone. | `list(map(any))` | `[]` | No |
| `target_network` | Peering network. | `string` | `""` | No |
| `description` | zone description (shown in console) | `string` | `"Managed by Terraform"` | No |
| `type` | Type of zone to create, valid values are 'public', 'private', 'forwarding', 'peering', 'reverse_lookup' and 'service_directory'. | `string` | `"private"` | No |
| `dnssec_config` | Object containing : kind, non_existence, state. Please see https://www.terraform.io/docs/providers/google/r/dns_managed_zone#dnssec_config for futhers details | `any` | `{` | No |
| `labels` | A set of key/value label pairs to assign to this ManagedZone | `map(any)` | `{` | No |
| `default_key_specs_key` | Object containing default key signing specifications : algorithm, key_length, key_type, kind. Please see https://www.terraform.io/docs/providers/google/r/dns_managed_zone#dnssec_config for futhers details | `any` | `{` | No |
| `default_key_specs_zone` | Object containing default zone signing specifications : algorithm, key_length, key_type, kind. Please see https://www.terraform.io/docs/providers/google/r/dns_managed_zone#dnssec_config for futhers details | `any` | `{` | No |
| `force_destroy` | Set this true to delete all records in the zone. | `bool` | `false` | No |
| `service_namespace_url` | n/a | `string` | `""` | No |
| `recordsets` | n/a | `list(object({` | n/a | Yes |
| `enable_logging` | Enable query logging for this ManagedZone | `bool` | `false` | No |
| `iam_choice` | Choose one of the following 'iam_binding', 'iam_member' or 'iam_policy' for managed zone iam | `string` | `null` | No |
| `member` | Identities the user/service account that will be granted the privilege in role (for case: managed_zone_iam_member) | `string` | `null` | No |
| `members` | Identities the users/service accounts that will be granted the privilege in role (for case: managed_zone_iam_policy, managed_zone_iam_binding) | `list(string)` | `null` | No |
| `role` | The role that should be applied | `string` | `null` | No |

## Outputs

| Name | Description |
|------|-------------|
| `type` | The DNS zone type. |
| `name` | The DNS zone name. |
| `domain` | The DNS zone domain. |
| `name_servers` | The DNS zone name servers. |
| `etag` | The etag of the IAM policy |
