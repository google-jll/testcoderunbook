# -------------------------------------------------------------------------------------
# 1. Notification Channels
# -------------------------------------------------------------------------------------
resource "google_monitoring_notification_channel" "channels" {
  for_each = var.project_id != null ? var.notification_channels : {}

  project      = var.project_id
  display_name = each.value.display_name
  type         = each.value.type
  labels       = each.value.labels
  user_labels  = each.value.user_labels
  enabled      = each.value.enabled

  dynamic "sensitive_labels" {
    for_each = each.value.sensitive_labels != null ? [each.value.sensitive_labels] : []
    content {
      auth_token  = sensitive_labels.value.auth_token
      password    = sensitive_labels.value.password
      service_key = sensitive_labels.value.service_key
    }
  }
}

# -------------------------------------------------------------------------------------
# 2. Alert Policies
# -------------------------------------------------------------------------------------
resource "google_monitoring_alert_policy" "alerts" {
  for_each = var.project_id != null ? var.alert_policies : {}

  project      = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner
  enabled      = each.value.enabled
  severity     = each.value.severity
  user_labels  = each.value.user_labels

  notification_channels = [
    for ch in each.value.notification_channels : (
      contains(keys(google_monitoring_notification_channel.channels), ch) ?
      google_monitoring_notification_channel.channels[ch].id : ch
    )
  ]

  # Alert Strategy (Automatically populates notification_rate_limit for log-based alerts if unspecified)
  dynamic "alert_strategy" {
    for_each = (each.value.alert_strategy != null || each.value.condition_matched_log != null) ? [1] : []
    content {
      auto_close = try(each.value.alert_strategy.auto_close, null)

      dynamic "notification_rate_limit" {
        for_each = (
          try(each.value.alert_strategy.notification_rate_limit, null) != null ||
          each.value.condition_matched_log != null
        ) ? [1] : []
        content {
          period = try(
            each.value.alert_strategy.notification_rate_limit.period,
            "3600s"
          )
        }
      }
    }
  }

  # Condition: Threshold (e.g. CPU > 85%)
  dynamic "conditions" {
    for_each = each.value.condition_threshold != null ? [each.value.condition_threshold] : []
    content {
      display_name = "${each.value.display_name} - Threshold Condition"

      condition_threshold {
        filter                  = conditions.value.filter
        duration                = conditions.value.duration
        comparison              = conditions.value.comparison
        threshold_value         = conditions.value.threshold_value
        evaluation_missing_data = conditions.value.evaluation_missing_data

        dynamic "aggregations" {
          for_each = conditions.value.aggregations
          content {
            alignment_period     = aggregations.value.alignment_period
            per_series_aligner   = aggregations.value.per_series_aligner
            cross_series_reducer = aggregations.value.cross_series_reducer
            group_by_fields      = aggregations.value.group_by_fields
          }
        }

        dynamic "trigger" {
          for_each = conditions.value.trigger != null ? [conditions.value.trigger] : []
          content {
            count   = trigger.value.count
            percent = trigger.value.percent
          }
        }
      }
    }
  }

  # Condition: Metric Absence (e.g. Heartbeat missing)
  dynamic "conditions" {
    for_each = each.value.condition_absent != null ? [each.value.condition_absent] : []
    content {
      display_name = "${each.value.display_name} - Metric Absence Condition"

      condition_absent {
        filter   = conditions.value.filter
        duration = conditions.value.duration

        dynamic "aggregations" {
          for_each = conditions.value.aggregations
          content {
            alignment_period     = aggregations.value.alignment_period
            per_series_aligner   = aggregations.value.per_series_aligner
            cross_series_reducer = aggregations.value.cross_series_reducer
            group_by_fields      = aggregations.value.group_by_fields
          }
        }
      }
    }
  }

  # Condition: Matched Log (Log-based alerting)
  dynamic "conditions" {
    for_each = each.value.condition_matched_log != null ? [each.value.condition_matched_log] : []
    content {
      display_name = "${each.value.display_name} - Log Match Condition"

      condition_matched_log {
        filter           = conditions.value.filter
        label_extractors = conditions.value.label_extractors
      }
    }
  }

  # Condition: Prometheus Query (PromQL)
  dynamic "conditions" {
    for_each = each.value.condition_prometheus_query != null ? [each.value.condition_prometheus_query] : []
    content {
      display_name = "${each.value.display_name} - PromQL Condition"

      condition_prometheus_query {
        query               = conditions.value.query
        duration            = conditions.value.duration
        evaluation_interval = conditions.value.evaluation_interval
        rule_group          = conditions.value.rule_group
      }
    }
  }

  dynamic "documentation" {
    for_each = each.value.documentation != null ? [each.value.documentation] : []
    content {
      content   = documentation.value.content
      mime_type = documentation.value.mime_type
    }
  }

  depends_on = [google_monitoring_notification_channel.channels]
}

# -------------------------------------------------------------------------------------
# 3. Custom Dashboards
# -------------------------------------------------------------------------------------
resource "google_monitoring_dashboard" "dashboards" {
  for_each = var.project_id != null ? var.dashboards : {}

  project        = var.project_id
  dashboard_json = each.value.dashboard_json
}

# -------------------------------------------------------------------------------------
# 4. Custom Metric Descriptors
# -------------------------------------------------------------------------------------
resource "google_monitoring_metric_descriptor" "metrics" {
  for_each = var.project_id != null ? var.metric_descriptors : {}

  project     = var.project_id
  type        = "custom.googleapis.com/${each.key}"
  metric_kind = each.value.metric_kind
  value_type  = each.value.value_type
  unit        = each.value.unit
  description = each.value.description

  dynamic "labels" {
    for_each = each.value.labels
    content {
      key         = labels.value.key
      value_type  = labels.value.value_type
      description = labels.value.description
    }
  }
}

# -------------------------------------------------------------------------------------
# 5. Uptime Check Configurations (Synthetic availability monitoring)
# -------------------------------------------------------------------------------------
resource "google_monitoring_uptime_check_config" "uptime_checks" {
  for_each = var.project_id != null ? var.uptime_checks : {}

  project          = var.project_id
  display_name     = each.value.display_name
  timeout          = each.value.timeout
  period           = each.value.period
  selected_regions = each.value.selected_regions

  dynamic "http_check" {
    for_each = each.value.http_check != null ? [each.value.http_check] : []
    content {
      path           = http_check.value.path
      port           = http_check.value.port
      use_ssl        = http_check.value.use_ssl
      validate_ssl   = http_check.value.validate_ssl
      request_method = http_check.value.request_method
      headers        = http_check.value.headers

      dynamic "auth_info" {
        for_each = http_check.value.auth_info != null ? [http_check.value.auth_info] : []
        content {
          username = auth_info.value.username
          password = auth_info.value.password
        }
      }
    }
  }

  dynamic "tcp_check" {
    for_each = each.value.tcp_check != null ? [each.value.tcp_check] : []
    content {
      port = tcp_check.value.port
    }
  }

  dynamic "monitored_resource" {
    for_each = each.value.monitored_resource != null ? [each.value.monitored_resource] : []
    content {
      type   = monitored_resource.value.type
      labels = monitored_resource.value.labels
    }
  }

  dynamic "content_matchers" {
    for_each = each.value.content_matchers != null ? each.value.content_matchers : []
    content {
      content = content_matchers.value.content
      matcher = content_matchers.value.matcher
    }
  }
}
