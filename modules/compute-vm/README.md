# Compute VM

A collection of Compute Engine building-block modules, vendored from
[`terraform-google-modules/terraform-google-vm`](https://github.com/terraform-google-modules/terraform-google-vm)
(Apache License 2.0). Each submodule is standalone and lives in its own
directory — there is no top-level composition module. Compose them in your
root/deploy config (see [`examples/compute-vm`](../../examples/compute-vm) for
runnable compositions).

The resource code lives in-repo rather than being sourced from the Terraform
Registry so it can be reviewed and modified directly.

## Submodules

| Module | Description |
|--------|-------------|
| [`instance_template`](./instance_template) | Creates a `google_compute_instance_template` (boot disk, networking, service account, Shielded/Confidential VM, GPU). |
| [`mig`](./mig) | Regional (flexible) `google_compute_region_instance_group_manager`, auto-healing health checks, and an optional regional autoscaler. |
| [`compute_instance`](./compute_instance) | Creates one or more `google_compute_instance_from_template` instances from an instance template. |
| [`compute_disk_snapshot`](./compute_disk_snapshot) | Creates a `google_compute_resource_policy` snapshot schedule and attaches it to disks. |
| [`mig_with_percent`](./mig_with_percent) | MIG that splits capacity across two instance templates by percentage (e.g. spot + regular). |
| [`preemptible_and_regular_instance_templates`](./preemptible_and_regular_instance_templates) | Builds a preemptible/spot template and a regular template for use with `mig_with_percent`. |

The upstream `umig` and (standalone) `preemptible` example variants are
intentionally omitted; the `preemptible_and_regular_instance_templates` module is
retained only because the `mig_with_percent` example depends on it.

## Usage

Reference a submodule directly by its path, e.g.:

```hcl
module "instance_template" {
  source = "../../modules/compute-vm/instance_template"
  # ...
}

module "mig" {
  source            = "../../modules/compute-vm/mig"
  instance_template = module.instance_template.self_link
  # ...
}
```
