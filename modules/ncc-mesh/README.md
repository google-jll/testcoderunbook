# GCP Terraform Module: NCC Mesh

This module provisions and manages **Network Connectivity Center (NCC) Mesh** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

It supports two operational modes:
1. **Hub & Spoke Creation (Default)**: Creates a new NCC Mesh hub (with optional auto-accept default group) and attaches any initial spokes (`create_hub = true`).
2. **Spoke-Only Attachment**: Attaches spokes to an existing NCC Mesh hub without managing the hub resource itself (`create_hub = false`), enabling decentralized spoke onboarding from different projects or stages.

---

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_network_connectivity_hub`** (conditional): `hub` (created when `create_hub = true`)
- **`google_network_connectivity_group`** (conditional): `default` (managed when `create_hub = true` and `auto_accept_projects` is non-empty)
- **`google_network_connectivity_spoke`** (dynamic): `vpc_spoke`, `producer_vpc_network_spoke`, `hybrid_spoke`, `router_appliance_spoke`

---

## Usage Examples

### 1. Creating an NCC Mesh Hub with Initial Spokes

```hcl
module "ncc_mesh" {
  source = "../../modules/ncc-mesh"

  project_id          = "hub-project-id"
  ncc_hub_name        = "corp-mesh-hub"
  ncc_hub_description = "Enterprise mesh hub with any-to-any connectivity"

  # Optional auto-accept for spoke projects
  auto_accept_projects = ["workload-project-1", "workload-project-2"]

  vpc_spokes = {
    "spoke-core" = {
      uri = "projects/hub-project-id/global/networks/core-vpc"
    }
  }
}
```

### 2. Attaching a Standalone Spoke to an Existing NCC Mesh Hub

```hcl
module "ncc_spoke" {
  source = "../../modules/ncc-mesh"

  project_id = "workload-project-id"
  create_hub = false

  # Reference the existing hub by full ID or by name + project
  ncc_hub_id = "projects/hub-project-id/locations/global/hubs/corp-mesh-hub"

  vpc_spokes = {
    "spoke-workload" = {
      uri         = "projects/workload-project-id/global/networks/workload-vpc"
      description = "Workload VPC spoke attached to existing mesh hub"
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
| `project_id` | Project ID of the project that holds the network or spoke. | `string` | n/a | **Yes** |
| `create_hub` | Whether to create the NCC Hub resource. Set to `false` to attach spokes to an existing NCC Hub without managing the hub resource. | `bool` | `true` | No |
| `ncc_hub_name` | Name of the NCC Hub (required when `create_hub` is `true`, or when `create_hub` is `false` and `ncc_hub_id` is omitted). | `string` | `null` | No |
| `ncc_hub_id` | Resource ID / URI of an existing NCC Hub to attach spokes to (e.g. `projects/<project>/locations/global/hubs/<hub-name>`). | `string` | `null` | No |
| `ncc_hub_project` | GCP project where the existing NCC Hub resides (used when `create_hub` is `false` and `ncc_hub_name` is supplied instead of `ncc_hub_id`). Defaults to `project_id`. | `string` | `null` | No |
| `ncc_hub_description` | Description of the NCC Hub. | `string` | `null` | No |
| `ncc_hub_labels` | Labels to attach to the NCC Hub. | `map(string)` | `{}` | No |
| `export_psc` | Whether Private Service Connect transitivity is enabled for the hub. | `bool` | `false` | No |
| `auto_accept_projects` | Project IDs (or numbers) whose spokes are automatically accepted into the mesh hub's `default` group. | `list(string)` | `[]` | No |
| `vpc_spokes` | VPC network spokes to attach to the hub. In a mesh hub, all spokes reach each other any-to-any. | `map(object({...}))` | `{}` | No |
| `hybrid_spokes` | VLAN attachments and VPN Tunnels associated with the spoke (`interconnect` or `vpn`). | `map(object({...}))` | `{}` | No |
| `router_appliance_spokes` | Router appliance instances associated with the spoke. | `map(object({...}))` | `{}` | No |
| `spoke_labels` | Labels added to all NCC spokes created by this module. | `map(string)` | `{}` | No |

---

## Outputs

| Name | Description |
|------|-------------|
| `ncc_hub` | The created NCC Hub object (`null` if `create_hub` is `false`). |
| `ncc_hub_id` | The NCC Hub ID/URI used by spokes. |
| `default_group` | The managed `default` group object (`null` unless `create_hub` is `true` and `auto_accept_projects` is set). |
| `vpc_spokes` | All VPC spoke objects. |
| `producer_vpc_network_spoke` | All producer network VPC spoke objects. |
| `hybrid_spokes` | All hybrid spoke objects. |
| `router_appliance_spokes` | All router appliance spoke objects. |
| `spokes` | All spoke objects prefixed with the spoke type (`vpc/`, `hybrid/`, `appliance/`, `producer-vpc/`). |
