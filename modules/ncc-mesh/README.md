# GCP Terraform Module: Ncc Mesh

This module provisions and manages **Ncc Mesh** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_network_connectivity_group`** (1 instance): `default`
- **`google_network_connectivity_hub`** (1 instance): `hub`
- **`google_network_connectivity_spoke`** (4 instances): `vpc_spoke`, `producer_vpc_network_spoke`, `hybrid_spoke`, `router_appliance_spoke`

## Usage Example

```hcl
module "ncc_mesh" {
  source = "../../modules/ncc-mesh"

  project_id = var.project_id
  ncc_hub_name = var.ncc_hub_name
  vpc_spokes = var.vpc_spokes
  hybrid_spokes = var.hybrid_spokes
  router_appliance_spokes = var.router_appliance_spokes
  # ncc_hub_description = null
  # ncc_hub_labels = {
  # export_psc = false
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
| `ncc_hub_name` | The Name of the NCC Hub | `string` | n/a | Yes |
| `project_id` | Project ID of the project that holds the network. | `string` | n/a | Yes |
| `auto_accept_projects` | Project IDs (or numbers) whose spokes are automatically accepted into the     mesh hub's `default` group. When non-empty, the module manages that group to     set auto-accept. NOTE: a mesh hub's `default` group is auto-created together     with the hub, so on an existing hub you must import it first, e.g.:     `terraform import '<addr>.google_network_connectivity_group.default[0]' projects/<project>/locations/global/hubs/<hub>/groups/default` | `list(string)` | `[]` | No |
| `export_psc` | Whether Private Service Connect transitivity is enabled for the hub | `bool` | `false` | No |
| `hybrid_spokes` | VLAN attachments and VPN Tunnels that are associated with the spoke. Type must be one of `interconnect` and `vpn`. | `map(object({ location = string uris = set(string) site_to_site_data_transfer = optional(bool, false) type = string description = optional(string) labels = optional(map(string)) include_import_ranges = optional(list(string), []) }))` | `{}` | No |
| `ncc_hub_description` | The description of the NCC Hub | `string` | `null` | No |
| `ncc_hub_labels` | These labels will be added the NCC hub | `map(string)` | `{}` | No |
| `router_appliance_spokes` | Router appliance instances that are associated with the spoke. | `map(object({ instances = set(object({ virtual_machine = string ip_address = string })) location = string site_to_site_data_transfer = optional(bool, false) description = optional(string) labels = optional(map(string)) include_import_ranges = optional(list(string), []) }))` | `{}` | No |
| `spoke_labels` | These labels will be added to all NCC spokes | `map(string)` | `{}` | No |
| `vpc_spokes` | VPC network that is associated with the spoke. link_producer_vpc_network: Producer VPC network that is peered with vpc network. In a mesh hub all spokes reach each other any-to-any, so no group assignment is needed. | `map(object({ uri = string exclude_export_ranges = optional(set(string), []) include_export_ranges = optional(set(string), []) description = optional(string) labels = optional(map(string)) link_producer_vpc_network = optional(object({ network_name = string peering = string include_export_ranges = optional(list(string)) exclude_export_ranges = optional(list(string)) description = optional(string) labels = optional(map(string)) })) }))` | `{}` | No |
## Outputs

| Name | Description |
|------|-------------|
| `default_group` | The managed `default` group object (null unless auto_accept_projects is set). |
| `hybrid_spokes` | All hybrid spoke objects |
| `ncc_hub` | The NCC Hub object |
| `producer_vpc_network_spoke` | All producer network vpc spoke objects |
| `router_appliance_spokes` | All router appliance spoke objects |
| `spokes` | All spoke objects prefixed with the type of spoke (vpc, hybrid, appliance) |
| `vpc_spokes` | All vpc spoke objects |
