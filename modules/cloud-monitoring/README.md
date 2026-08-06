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
| `project_id` | Optional. GCP Project ID where monitoring resources are created. | `string` | `null` | **No** |
| `notification_channels` | Map of notification channels to create (email, pubsub, webhook, slack, pagerduty). | `map(object)` | `{}` | **No** |
| `alert_policies` | Map of alert policy configurations. | `map(object)` | `{}` | **No** |
| `dashboards` | Map of JSON dashboard definitions. | `map(object)` | `{}` | **No** |
| `metric_descriptors` | Map of custom metric descriptor definitions. | `map(object)` | `{}` | **No** |
| `uptime_checks` | Map of synthetic Uptime Check configurations. | `map(object)` | `{}` | **No** |

---

## Outputs

| Name | Description |
|------|-------------|
| `notification_channels` | Map of created notification channel objects. |
| `notification_channel_ids` | Map of short channel names to notification channel IDs. |
| `alert_policies` | Map of created alert policy objects. |
| `alert_policy_ids` | Map of short alert names to alert policy IDs. |
| `dashboards` | Map of created dashboard objects. |
| `dashboard_ids` | Map of short dashboard names to dashboard IDs. |
| `metric_descriptors` | Map of created custom metric descriptors. |
| `uptime_checks` | Map of created uptime check objects. |
| `uptime_check_ids` | Map of short check names to uptime check IDs. |
