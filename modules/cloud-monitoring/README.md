# GCP Cloud Monitoring Terraform Module

This module manages **Google Cloud Monitoring** resources in Google Cloud Platform (GCP). All resource categories—**Notification Channels**, **Alert Policies** (Threshold, Absence, Log Match, PromQL), **Custom Dashboards**, **Custom Metric Descriptors**, and **Synthetic Uptime Checks**—are **100% modular and optional**. You can deploy individual resources selectively (e.g. Notification Channels only) or provision a complete monitoring stack.

---

## Features

- **Notification Channels (`google_monitoring_notification_channel`)**: Supports Email, Pub/Sub, Webhooks, Slack, PagerDuty, and sensitive channel labels (`auth_token`, `password`, `service_key`).
- **Alert Policies (`google_monitoring_alert_policy`)**:
  - **Threshold Conditions**: Alert on metric values exceeding or dropping below thresholds (e.g., CPU > 85%).
  - **Metric Absence Conditions**: Alert on missing telemetry or stopped VM heartbeats.
  - **Log-matched Alerting**: Alert directly on specific Cloud Logging log entries (e.g., `CRITICAL` severity errors) with automatic default rate-limiting (`notification_rate_limit`) to satisfy GCP API requirements.
  - **PromQL Alerting**: PromQL queries for Google Cloud Managed Service for Prometheus.
  - **Alert Strategies**: Auto-close duration and notification rate limiting.
- **Custom Dashboards (`google_monitoring_dashboard`)**: Provisions operational dashboards using native JSON definitions.
- **Custom Metric Descriptors (`google_monitoring_metric_descriptor`)**: Defines custom application metrics (`GAUGE`, `DELTA`, `CUMULATIVE`) with custom labels.
- **Synthetic Uptime Checks (`google_monitoring_uptime_check_config`)**: Monitors HTTP/HTTPS or TCP endpoint availability from global GCP probe regions with SSL validation and content matchers.

---

## Modular & Selective Use Cases

### Use Case 1: Notification Channels Only
Create notification channels without provisioning any alert policies or dashboards.

```hcl
module "monitoring_channels" {
  source = "../../modules/cloud-monitoring"

  project_id = "my-gcp-project-id"

  notification_channels = {
    "ops-email" = {
      display_name = "Ops Team Email"
      type         = "email"
      labels       = { email_address = "ops@example.com" }
    }
  }
}
```

### Use Case 2: Alert Policies Only (Linking to Existing Channel IDs)
Provision alert policies without creating new notification channels.

```hcl
module "monitoring_alerts" {
  source = "../../modules/cloud-monitoring"

  project_id = "my-gcp-project-id"

  alert_policies = {
    "high-cpu" = {
      display_name          = "High CPU Alert"
      combiner              = "OR"
      severity              = "CRITICAL"
      notification_channels = ["projects/my-gcp-project-id/notificationChannels/123456789"]

      condition_threshold = {
        filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
        duration        = "300s"
        comparison      = "COMPARISON_GT"
        threshold_value = 0.85
      }
    }
  }
}
```

### Use Case 3: Custom Dashboards Only
Deploy operational dashboards using JSON definitions.

```hcl
module "monitoring_dashboards" {
  source = "../../modules/cloud-monitoring"

  project_id = "my-gcp-project-id"

  dashboards = {
    "ops-dashboard" = {
      dashboard_json = jsonencode({
        displayName = "Operations Overview"
        gridLayout  = { columns = 1, widgets = [] }
      })
    }
  }
}
```

### Use Case 4: Custom Metric Descriptors Only
Register custom application metrics with custom labels.

```hcl
module "monitoring_metrics" {
  source = "../../modules/cloud-monitoring"

  project_id = "my-gcp-project-id"

  metric_descriptors = {
    "app_requests" = {
      metric_kind = "DELTA"
      value_type  = "INT64"
      unit        = "1"
      description = "Count of processed application requests"
    }
  }
}
```

### Use Case 5: Synthetic Uptime Checks Only
Provision synthetic HTTP availability checks.

```hcl
module "monitoring_uptime" {
  source = "../../modules/cloud-monitoring"

  project_id = "my-gcp-project-id"

  uptime_checks = {
    "api-health" = {
      display_name     = "API Health Check"
      period           = "300s"
      selected_regions = ["USA", "EUROPE"]
      http_check = {
        path    = "/healthz"
        port    = 443
        use_ssl = true
      }
      monitored_resource = {
        type   = "uptime_url"
        labels = { host = "api.example.com" }
      }
    }
  }
}
```

### Use Case 6: Full Enterprise Monitoring Stack
Deploy channels, alerts, custom metrics, dashboards, and synthetic uptime checks together.

```hcl
module "monitoring_full" {
  source = "../../modules/cloud-monitoring"

  project_id = "my-gcp-project-id"

  notification_channels = {
    "devops-email" = {
      display_name = "DevOps Email"
      type         = "email"
      labels       = { email_address = "devops@example.com" }
    }
  }

  alert_policies = {
    "high-cpu" = {
      display_name          = "High CPU Alert"
      severity              = "CRITICAL"
      notification_channels = ["devops-email"]
      condition_threshold = {
        filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
        duration        = "300s"
        comparison      = "COMPARISON_GT"
        threshold_value = 0.85
      }
    }
  }

  dashboards = {
    "ops-dashboard" = {
      dashboard_json = jsonencode({ displayName = "Operations Dashboard", gridLayout = { columns = 2 } })
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
| `alert_policies` | Map of Cloud Monitoring alert policies to create. | `map(object({ display_name = string combiner = optional(string, "OR") # "OR" or "AND" enabled = optional(bool, true) severity = optional(string, "WARNING") # "CRITICAL", "ERROR", "WARNING" user_labels = optional(map(string), {}) notification_channels = optional(list(string), []) # References keys in var.notification_channels or direct channel IDs alert_strategy = optional(object({ auto_close = optional(string) # e.g. "604800s", "1800s" notification_rate_limit = optional(object({ period = optional(string, "3600s") })) })) # Threshold condition condition_threshold = optional(object({ filter = string duration = string # e.g. "60s", "300s" comparison = string # "COMPARISON_GT", "COMPARISON_GE", "COMPARISON_LT", "COMPARISON_LE" threshold_value = number evaluation_missing_data = optional(string) # "EVALUATION_MISSING_DATA_INACTIVE", "EVALUATION_MISSING_DATA_ACTIVE" aggregations = optional(list(object({ alignment_period = string per_series_aligner = string cross_series_reducer = optional(string) group_by_fields = optional(list(string)) })), []) trigger = optional(object({ count = optional(number) percent = optional(number) })) })) # Metric absence condition condition_absent = optional(object({ filter = string duration = string # e.g. "300s" aggregations = optional(list(object({ alignment_period = string per_series_aligner = string cross_series_reducer = optional(string) group_by_fields = optional(list(string)) })), []) })) # Log match condition (Log-based alerting) condition_matched_log = optional(object({ filter = string label_extractors = optional(map(string)) })) # Prometheus condition (PromQL) condition_prometheus_query = optional(object({ query = string duration = optional(string, "60s") evaluation_interval = optional(string, "60s") rule_group = optional(string) })) documentation = optional(object({ content = string mime_type = optional(string, "text/markdown") })) }))` | `{}` | No |
| `dashboards` | Map of Cloud Monitoring dashboards to create using JSON definitions. | `map(object({ dashboard_json = string # Full JSON string defining the dashboard layout }))` | `{}` | No |
| `metric_descriptors` | Map of custom metric descriptors to create. | `map(object({ metric_kind = string # "GAUGE", "DELTA", "CUMULATIVE" value_type = string # "BOOL", "INT64", "DOUBLE", "STRING", "DISTRIBUTION" unit = optional(string, "1") description = optional(string) labels = optional(list(object({ key = string value_type = optional(string, "STRING") description = optional(string) })), []) }))` | `{}` | No |
| `notification_channels` | Map of notification channels to create (email, pubsub, webhook, slack, pagerduty). | `map(object({ display_name = string type = string # e.g. "email", "pubsub", "webhook", "slack", "pagerduty" labels = map(string) user_labels = optional(map(string), {}) enabled = optional(bool, true) sensitive_labels = optional(object({ auth_token = optional(string) password = optional(string) service_key = optional(string) })) }))` | `{}` | No |
| `project_id` | Optional. The GCP project ID where Cloud Monitoring resources will be created. If set to null, resource creation is skipped. | `string` | `null` | No |
| `uptime_checks` | Map of synthetic Uptime Check configurations. | `map(object({ display_name = string timeout = optional(string, "10s") period = optional(string, "300s") selected_regions = optional(list(string), []) http_check = optional(object({ path = optional(string, "/") port = optional(number, 443) use_ssl = optional(bool, true) validate_ssl = optional(bool, true) request_method = optional(string, "GET") headers = optional(map(string), {}) auth_info = optional(object({ username = string password = string })) })) tcp_check = optional(object({ port = number })) monitored_resource = optional(object({ type = string # e.g. "uptime_url", "gce_instance" labels = map(string) })) content_matchers = optional(list(object({ content = string matcher = optional(string, "CONTAINS_STRING") })), []) }))` | `{}` | No |
## Outputs

| Name | Description |
|------|-------------|
| `alert_policies` | Map of created alert policy objects. |
| `alert_policy_ids` | Map of alert policy short names to alert policy IDs. |
| `dashboard_ids` | Map of dashboard short names to dashboard IDs. |
| `dashboards` | Map of created dashboard objects. |
| `metric_descriptors` | Map of created custom metric descriptors. |
| `notification_channel_ids` | Map of channel short names to notification channel IDs. |
| `notification_channels` | Map of created notification channel objects. |
| `uptime_check_ids` | Map of uptime check short names to uptime check IDs. |
| `uptime_checks` | Map of created uptime check configuration objects. |
