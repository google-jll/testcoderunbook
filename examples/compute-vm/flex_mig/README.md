# Flexible MIG Example (multiple machine types)

This example provisions a **flexible regional managed instance group** — a MIG that
creates VMs from *any of several machine types* (`instance_flexibility_policy`) rather
than a single fixed shape — using the [`compute-vm/mig`](../../../modules/compute-vm/mig)
and [`compute-vm/instance_template`](../../../modules/compute-vm/instance_template) modules.

Compute Engine picks a machine type per instance based on the `rank` you set (lowest
first) and current capacity, falling back to the next selection when a shape is short.
This is distinct from `distribution_policy_target_shape`, which controls *zone* spread —
see the sibling [`mig`](../mig) example for that.

## What it creates

- A self-contained VPC network + subnet (`flex-mig-example-*`, `10.20.0.0/24`).
- An instance template (base `n2-standard-2`, overridden per selection).
- A flexible regional MIG with `target_size` instances spread across the machine
  types `n2-standard-2` (rank 0) → `n2d-standard-2` (rank 1) → `e2-standard-2` (rank 2),
  publishing a named port `http:80` so a load balancer can target it.

## Usage

```bash
terraform init
terraform plan  -var 'project_id=my-project'
terraform apply -var 'project_id=my-project'
```

Verify the flexibility policy after apply:

```bash
gcloud compute instance-groups managed describe flex-mig-mig \
  --region=us-central1 --project=my-project \
  --format='yaml(instanceFlexibilityPolicy)'
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The GCP project to create the resources in. | `string` | n/a | yes |
| `region` | Region for the subnet and the flexible MIG. | `string` | `"us-central1"` | no |
| `target_size` | Target number of running instances. | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| `self_link` | Self link of the flexible MIG. |
| `instance_group` | Instance-group URL (use as an LB backend). |
| `region` | The region the MIG was created in. |
