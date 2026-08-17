# GCP Terraform Module: Compute Vm - Compute Disk Snapshot

This module provisions and manages **Compute Vm - Compute Disk Snapshot** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_disk_resource_policy_attachment`** (1 instance): `attachment`
- **`google_compute_resource_policy`** (1 instance): `policy`
- **`null_resource`** (1 instance): `module_depends_on`

## Usage Example

```hcl
module "compute_disk_snapshot" {
  source = "../../modules/compute-vm/compute_disk_snapshot"

  name = var.name
  project = var.project
  region = var.region
  snapshot_retention_policy = var.snapshot_retention_policy
  snapshot_schedule = var.snapshot_schedule
  snapshot_properties = var.snapshot_properties
  # disks = []
  # module_depends_on = []
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
| `name` | Name of the resource policy to create | `string` | n/a | Yes |
| `project` | The project ID where the resources will be created | `string` | n/a | Yes |
| `region` | Region where resource policy resides | `string` | n/a | Yes |
| `snapshot_retention_policy` | The retention policy to be applied to the schedule policy. For more details see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy#retention_policy | `object( { max_retention_days = number on_source_disk_delete = string } )` | n/a | Yes |
| `snapshot_schedule` | The scheduled to be used by the snapshot policy. For more details see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy#schedule | `object( { daily_schedule = object( { days_in_cycle = number start_time = string } ) hourly_schedule = object( { hours_in_cycle = number start_time = string } ) weekly_schedule = object( { day_of_weeks = set(object( { day = string start_time = string } )) } ) } )` | n/a | Yes |
| `disks` | List of self_links persistent disks to attach the snapshot policy to (ie. projects/project_id/disks/diskname/zones/zone_name) | `list(string)` | `[]` | No |
| `module_depends_on` | List of modules or resources this module depends on | `list(any)` | `[]` | No |
| `snapshot_properties` | The properties of the schedule policy. For more details see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy#snapshot_properties | `object( { guest_flush = bool labels = map(string) storage_locations = list(string) } )` | `null` | No |
## Outputs

| Name | Description |
|------|-------------|
| `attachments` | Disk attachments to the resource policy. |
| `policy` | Resource snapshot policy details. |
