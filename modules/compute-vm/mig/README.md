# GCP Terraform Module: Compute Vm - Mig

This module provisions and manages **Compute Vm - Mig** infrastructure resources on Google Cloud Platform following enterprise foundation standards.

## Resources Provisioned

This module manages the following Google Cloud Platform resources:

- **`google_compute_health_check`** (3 instances): `https`, `http`, `tcp`
- **`google_compute_region_autoscaler`** (1 instance): `autoscaler`
- **`google_compute_region_instance_group_manager`** (1 instance): `mig`

## Usage Example

```hcl
module "mig" {
  source = "../../modules/compute-vm/mig"

  project_id = var.project_id
  region = var.region
  instance_template = var.instance_template
  stateful_disks = var.stateful_disks
  stateful_ips = var.stateful_ips
  update_policy = var.update_policy
  health_check = var.health_check
  autoscaling_cpu = var.autoscaling_cpu
  autoscaling_metric = var.autoscaling_metric
  scaling_schedules = var.scaling_schedules
  autoscaling_scale_in_control = var.autoscaling_scale_in_control
  named_ports = var.named_ports
  mig_timeouts = var.mig_timeouts
  # mig_name = ""
  # hostname = "default"
  # target_size = 1
}
```

## Flexible ("flex") MIG

Set `instance_selections` to make the MIG a **flexible** instance group: instead of a
single fixed machine type, the MIG creates VMs from any of the machine types you list,
preferring the lowest `rank` and falling back when a shape is short on capacity. The
instance template still supplies the base config (image, disks, network); the
selection's `machine_types` override the template's `machine_type`.

```hcl
module "mig" {
  source = "../../modules/compute-vm/mig"

  project_id        = var.project_id
  region            = var.region
  instance_template = var.instance_template
  target_size       = 3
  named_ports       = [{ name = "http", port = 80 }]

  # Flex: create VMs from any of these types, n2 first.
  instance_selections = {
    "n2"  = { machine_types = ["n2-standard-2"], rank = 0 }
    "n2d" = { machine_types = ["n2d-standard-2"], rank = 1 }
    "e2"  = { machine_types = ["e2-standard-2"], rank = 2 }
  }

  # Optional standby pool of pre-created stopped VMs for faster scale-out.
  # standby_policy      = { initial_delay_sec = 60, mode = "SCALE_OUT_POOL" }
  # target_stopped_size = 2
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
| `project_id` | The Google Cloud project ID | `string` | n/a | Yes |
| `region` | The Google Cloud region where the managed instance group resides. | `string` | n/a | Yes |
| `mig_name` | Managed instance group name. When variable is empty, name will be derived from var.hostname. | `string` | `""` | No |
| `hostname` | Hostname prefix for instances | `string` | `"default"` | No |
| `target_size` | The target number of running instances for this managed instance group. This value should always be explicitly set unless this resource is attached to an autoscaler, in which case it should never be set. | `number` | `1` | No |
| `instance_template` | Instance template self_link used to create compute instances | `string` | n/a | Yes |
| `target_pools` | The target load balancing pools to assign this group to. | `list(string)` | `[]` | No |
| `distribution_policy_target_shape` | MIG target distribution shape (EVEN, BALANCED, ANY, ANY_SINGLE_ZONE) | `string` | `null` | No |
| `distribution_policy_zones` | The distribution policy, i.e. which zone(s) should instances be create in. Default is all zones in given region. | `list(string)` | `[]` | No |
| `instance_selections` | Flex MIG: map (key = selection name) of `{ machine_types, rank }`. Non-empty makes the MIG flexible across the listed machine types. | `map(object)` | `{}` | No |
| `standby_policy` | Flex MIG standby policy `{ initial_delay_sec, mode }` (mode = `MANUAL` or `SCALE_OUT_POOL`). | `object` | `null` | No |
| `target_suspended_size` | Number of instances to keep suspended (requires `standby_policy`). | `number` | `null` | No |
| `target_stopped_size` | Number of instances to keep stopped (requires `standby_policy`). | `number` | `null` | No |
| `stateful_disks` | Disks created on the instances that will be preserved on instance delete. https://cloud.google.com/compute/docs/instance-groups/configuring-stateful-disks-in-migs | `list(object({` | n/a | Yes |
| `stateful_ips` | Statful IPs created on the instances that will be preserved on instance delete. https://cloud.google.com/compute/docs/instance-groups/configuring-stateful-ip-addresses-in-migs | `list(object({` | n/a | Yes |
| `update_policy` | The rolling update policy. https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager#rolling_update_policy | `list(object({` | n/a | Yes |
| `health_check_name` | Health check name. When variable is empty, name will be derived from var.hostname. | `string` | `""` | No |
| `health_check` | Health check to determine whether instances are responsive and able to do work | `object({` | n/a | Yes |
| `autoscaler_name` | Autoscaler name. When variable is empty, name will be derived from var.hostname. | `string` | `""` | No |
| `autoscaling_enabled` | Creates an autoscaler for the managed instance group | `string` | `"false"` | No |
| `max_replicas` | The maximum number of instances that the autoscaler can scale up to. This is required when creating or updating an autoscaler. The maximum number of replicas should not be lower than minimal number of replicas. | `number` | `10` | No |
| `min_replicas` | The minimum number of replicas that the autoscaler can scale down to. This cannot be less than 0. | `number` | `2` | No |
| `cooldown_period` | The number of seconds that the autoscaler should wait before it starts collecting information from a new instance. | `number` | `60` | No |
| `autoscaling_mode` | Operating mode of the autoscaling policy. If omitted, the default value is ON. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler#mode | `string` | `null` | No |
| `autoscaling_cpu` | Autoscaling, cpu utilization policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#cpu_utilization | `list(object({` | n/a | Yes |
| `autoscaling_metric` | Autoscaling, metric policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#metric | `list(object({` | n/a | Yes |
| `autoscaling_lb` | Autoscaling, load balancing utilization policy block as single element array. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#load_balancing_utilization | `list(map(number))` | `[]` | No |
| `scaling_schedules` | Autoscaling, scaling schedule block. https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler#scaling_schedules | `list(object({` | n/a | Yes |
| `autoscaling_scale_in_control` | Autoscaling, scale-in control block. https://www.terraform.io/docs/providers/google/r/compute_autoscaler#scale_in_control | `object({` | n/a | Yes |
| `named_ports` | Named name and named port. https://cloud.google.com/load-balancing/docs/backend-service#named_ports | `list(object({` | n/a | Yes |
| `wait_for_instances` | Whether to wait for all instances to be created/updated before returning. Note that if this is set to true and the operation does not succeed, Terraform will continue trying until it times out. | `string` | `"false"` | No |
| `mig_timeouts` | Times for creation, deleting and updating the MIG resources. Can be helpful when using wait_for_instances to allow a longer VM startup time.  | `object({` | n/a | Yes |
| `labels` | Labels, provided as a map | `map(string)` | `{` | No |

## Outputs

| Name | Description |
|------|-------------|
| `self_link` | Self-link of managed instance group |
| `instance_group` | Instance-group url of managed instance group |
| `instance_group_manager` | An instance of google_compute_region_instance_group_manager of the instance group. |
| `health_check_self_links` | All self_links of healthchecks created for the instance group. |
| `apphub_workload_uri` | n/a |
