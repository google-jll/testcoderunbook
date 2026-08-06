provider "google" {
  project = var.project_id
}

# -------------------------------------------------------------------------------------
# Invoke Cloud Monitoring Module (Optional when project_id != null)
# Supports selective resource creation (Notification Channels, Alerts, Dashboards, Custom Metrics, Uptime Checks)
# -------------------------------------------------------------------------------------
module "cloud_monitoring" {
  count  = var.project_id != null ? 1 : 0
  source = "../../modules/cloud-monitoring"

  project_id = var.project_id

  # 1. Optional Notification Channels
  notification_channels = var.enable_notification_channels ? {
    "devops-email" = {
      display_name = "DevOps Team Email Channel"
      type         = "email"
      labels       = { email_address = var.alert_email }
      user_labels  = { env = "production", team = "devops" }
    }
  } : {}

  # 2. Optional Alert Policies (Threshold, Absence, Log Match)
  # Uses merge() for individual policy maps so each alert policy schema is consistent
  alert_policies = merge(
    var.enable_alert_policies ? {
      "gce-high-cpu" = {
        display_name          = "Alert: Compute Engine High CPU Utilization (>85%)"
        combiner              = "OR"
        severity              = "CRITICAL"
        user_labels           = { severity = "critical", component = "gce" }
        notification_channels = var.enable_notification_channels ? ["devops-email"] : []

        alert_strategy = {
          auto_close = "604800s" # Auto close after 7 days if unhandled
        }

        condition_threshold = {
          filter                  = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
          duration                = "300s"
          comparison              = "COMPARISON_GT"
          threshold_value         = var.cpu_threshold
          evaluation_missing_data = "EVALUATION_MISSING_DATA_INACTIVE"
          aggregations = [{
            alignment_period   = "60s"
            per_series_aligner = "ALIGN_MEAN"
          }]
        }

        documentation = {
          content   = "## High CPU Utilization Alert\nCompute Engine instance CPU utilization exceeded threshold for 5 minutes."
          mime_type = "text/markdown"
        }
      }
    } : {},
    var.enable_alert_policies ? {
      "vm-absence-heartbeat" = {
        display_name          = "Alert: VM Instance Heartbeat Missing"
        combiner              = "OR"
        severity              = "ERROR"
        notification_channels = var.enable_notification_channels ? ["devops-email"] : []

        condition_absent = {
          filter   = "metric.type=\"compute.googleapis.com/instance/uptime\" AND resource.type=\"gce_instance\""
          duration = "300s"
          aggregations = [{
            alignment_period   = "60s"
            per_series_aligner = "ALIGN_RATE"
          }]
        }
      }
    } : {},
    var.enable_alert_policies ? {
      "gce-critical-log-alert" = {
        display_name          = "Alert: GCE Critical Severity Log Event"
        combiner              = "OR"
        severity              = "CRITICAL"
        notification_channels = var.enable_notification_channels ? ["devops-email"] : []

        condition_matched_log = {
          filter = "resource.type=\"gce_instance\" AND severity=CRITICAL"
        }
      }
    } : {}
  )

  # 3. Optional Custom Metric Descriptors
  metric_descriptors = var.enable_metric_descriptors ? {
    "app_active_connections" = {
      metric_kind = "GAUGE"
      value_type  = "INT64"
      unit        = "1"
      description = "Count of active user connections to application service"
      labels = [
        {
          key         = "region"
          value_type  = "STRING"
          description = "GCP deployment region"
        }
      ]
    }
  } : {}

  # 4. Optional Custom Dashboards
  dashboards = var.enable_dashboards ? {
    "exec-ops-dashboard" = {
      dashboard_json = jsonencode({
        displayName = "Executive Operations & Health Dashboard"
        gridLayout  = {
          columns = 2
          widgets = [
            {
              title = "CPU Utilization across GCE Instances"
              xyChart = {
                dataSets = [{
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
                    }
                  }
                }]
              }
            },
            {
              title = "Network Received Bytes"
              xyChart = {
                dataSets = [{
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"compute.googleapis.com/instance/network/received_bytes_count\""
                    }
                  }
                }]
              }
            }
          ]
        }
      })
    }
  } : {}

  # 5. Optional Synthetic Uptime Checks
  uptime_checks = var.enable_uptime_checks ? {
    "web-app-uptime" = {
      display_name     = "Web Application Availability Check"
      timeout          = "10s"
      period           = "300s"
      selected_regions = ["USA", "EUROPE"]
      http_check = {
        path         = "/"
        port         = 443
        use_ssl      = true
        validate_ssl = true
      }
      monitored_resource = {
        type   = "uptime_url"
        labels = { host = var.app_hostname }
      }
      content_matchers = [
        {
          content = "200 OK"
          matcher = "CONTAINS_STRING"
        }
      ]
    }
  } : {}
}
