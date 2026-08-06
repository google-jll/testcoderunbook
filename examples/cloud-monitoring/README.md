# GCP Cloud Monitoring Terraform Example

This example demonstrates how to provision **Google Cloud Monitoring** resources using the [`modules/cloud-monitoring`](../../modules/cloud-monitoring) foundation module. All monitoring components—**Notification Channels**, **Alert Policies**, **Custom Dashboards**, **Custom Metric Descriptors**, and **Synthetic Uptime Checks**—are fully optional and can be selectively enabled or disabled using boolean toggle flags or by omitting `project_id`.

---

## Supported Deployment Scenarios

### Scenario 1: Full Enterprise Monitoring Stack
Deploy notification channels, CPU/heartbeat/log alert policies, custom metric descriptors, operational dashboards, and synthetic HTTPS availability uptime checks together.

**`terraform.tfvars`**:
```hcl
project_id                    = "my-gcp-project-id"
alert_email                   = "devops-alerts@example.com"
enable_notification_channels = true
enable_alert_policies        = true
enable_metric_descriptors    = true
enable_dashboards             = true
enable_uptime_checks         = true
```

### Scenario 2: Notification Channels Only
Deploy notification channels (email, pubsub, etc.) without creating alert policies or dashboards.

**`terraform.tfvars`**:
```hcl
project_id                    = "my-gcp-project-id"
enable_notification_channels = true
enable_alert_policies        = false
enable_metric_descriptors    = false
enable_dashboards             = false
enable_uptime_checks         = false
```

### Scenario 3: Alert Policies Only
Deploy alert policies without creating notification channels or dashboards.

**`terraform.tfvars`**:
```hcl
project_id                    = "my-gcp-project-id"
enable_notification_channels = false
enable_alert_policies        = true
enable_metric_descriptors    = false
enable_dashboards             = false
enable_uptime_checks         = false
```

### Scenario 4: Custom Dashboards Only
Deploy operational dashboards using native JSON definitions without notification channels or alert policies.

**`terraform.tfvars`**:
```hcl
project_id                    = "my-gcp-project-id"
enable_notification_channels = false
enable_alert_policies        = false
enable_metric_descriptors    = false
enable_dashboards             = true
enable_uptime_checks         = false
```

### Scenario 5: Synthetic Uptime Checks Only
Deploy synthetic HTTP/HTTPS availability checks to monitor web app uptime from global GCP probe locations.

**`terraform.tfvars`**:
```hcl
project_id                    = "my-gcp-project-id"
app_hostname                  = "api.example.com"
enable_notification_channels = false
enable_alert_policies        = false
enable_metric_descriptors    = false
enable_dashboards             = false
enable_uptime_checks         = true
```

---

## Features & Scenarios Demonstrated

1. **DevOps Email Notification Channel**:
   - Creates an email notification channel recipient for alerting teams.
2. **Multi-Condition Alert Policies**:
   - **Threshold Alert (`gce-high-cpu`)**: Triggers when GCE CPU utilization exceeds 85% for 5 minutes with auto-close policy.
   - **Absence Alert (`vm-absence-heartbeat`)**: Triggers when VM heartbeat metrics are missing for 5 minutes.
   - **Log-matched Alert (`gce-critical-log-alert`)**: Triggers on `CRITICAL` severity GCE log events.
3. **Custom Metric Descriptor (`app_active_connections`)**:
   - Registers a custom `GAUGE` metric for tracking active user connections by region.
4. **Operations Dashboard (`exec-ops-dashboard`)**:
   - Renders a 2-column operational grid displaying CPU utilization and network bytes.
5. **Synthetic Availability Check (`web-app-uptime`)**:
   - Monitors HTTP availability every 5 minutes from USA and Europe probe locations with SSL validation and 200 OK content matchers.

---

## Prerequisites

- **Terraform**: `>= 1.3`
- **Google Cloud SDK**: Verified authentication (`gcloud auth application-default login`) with `roles/monitoring.admin` on the target project.
- **Required API**: Ensure `monitoring.googleapis.com` is enabled in your project.

---

## Usage & Execution Steps

```bash
# 1. Navigate to this directory
cd examples/cloud-monitoring

# 2. Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Set project_id and toggle flags for desired components!

# 3. Initialize Terraform plugins
terraform init

# 4. Review execution plan
terraform plan

# 5. Apply configuration
terraform apply

# 6. Clean up resources when done
terraform destroy
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | Optional target GCP project ID. Set `null` to skip resource creation. | `string` | `null` | **No** |
| `alert_email` | Recipient email address for DevOps notification channel. | `string` | `"devops-alerts@example.com"` | **No** |
| `cpu_threshold` | CPU utilization threshold (0.0 to 1.0) for high CPU alert policy. | `number` | `0.85` | **No** |
| `app_hostname` | Hostname for synthetic HTTP availability check. | `string` | `"example.com"` | **No** |
| `enable_notification_channels` | Boolean flag to toggle notification channel deployment. | `bool` | `true` | **No** |
| `enable_alert_policies` | Boolean flag to toggle alert policy deployment. | `bool` | `true` | **No** |
| `enable_metric_descriptors` | Boolean flag to toggle custom metric descriptor deployment. | `bool` | `true` | **No** |
| `enable_dashboards` | Boolean flag to toggle custom dashboard deployment. | `bool` | `true` | **No** |
| `enable_uptime_checks` | Boolean flag to toggle synthetic uptime check deployment. | `bool` | `true` | **No** |

---

## Outputs

| Name | Description |
|------|-------------|
| `notification_channel_ids` | Map of created notification channel IDs. |
| `alert_policy_ids` | Map of created alert policy IDs. |
| `dashboard_ids` | Map of created custom dashboard IDs. |
| `metric_descriptors` | Map of created custom metric descriptors. |
| `uptime_check_ids` | Map of created synthetic uptime check IDs. |
