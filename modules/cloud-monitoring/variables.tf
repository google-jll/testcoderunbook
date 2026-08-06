variable "project_id" {
  description = "Optional. The GCP project ID where Cloud Monitoring resources will be created. If set to null, resource creation is skipped."
  type        = string
  default     = null
}

variable "notification_channels" {
  description = "Map of notification channels to create (email, pubsub, webhook, slack, pagerduty)."
  type = map(object({
    display_name = string
    type         = string # e.g. "email", "pubsub", "webhook", "slack", "pagerduty"
    labels       = map(string)
    user_labels  = optional(map(string), {})
    enabled      = optional(bool, true)
    sensitive_labels = optional(object({
      auth_token  = optional(string)
      password    = optional(string)
      service_key = optional(string)
    }))
  }))
  default = {}
}

variable "alert_policies" {
  description = "Map of Cloud Monitoring alert policies to create."
  type = map(object({
    display_name          = string
    combiner              = optional(string, "OR") # "OR" or "AND"
    enabled               = optional(bool, true)
    severity              = optional(string, "WARNING") # "CRITICAL", "ERROR", "WARNING"
    user_labels           = optional(map(string), {})
    notification_channels = optional(list(string), []) # References keys in var.notification_channels or direct channel IDs
    
    alert_strategy = optional(object({
      auto_close = optional(string) # e.g. "604800s", "1800s"
      notification_rate_limit = optional(object({
        period = optional(string, "3600s")
      }))
    }))

    # Threshold condition
    condition_threshold = optional(object({
      filter                  = string
      duration                = string # e.g. "60s", "300s"
      comparison              = string # "COMPARISON_GT", "COMPARISON_GE", "COMPARISON_LT", "COMPARISON_LE"
      threshold_value         = number
      evaluation_missing_data = optional(string) # "EVALUATION_MISSING_DATA_INACTIVE", "EVALUATION_MISSING_DATA_ACTIVE"
      aggregations = optional(list(object({
        alignment_period     = string
        per_series_aligner   = string
        cross_series_reducer = optional(string)
        group_by_fields      = optional(list(string))
      })), [])
      trigger = optional(object({
        count   = optional(number)
        percent = optional(number)
      }))
    }))

    # Metric absence condition
    condition_absent = optional(object({
      filter   = string
      duration = string # e.g. "300s"
      aggregations = optional(list(object({
        alignment_period     = string
        per_series_aligner   = string
        cross_series_reducer = optional(string)
        group_by_fields      = optional(list(string))
      })), [])
    }))

    # Log match condition (Log-based alerting)
    condition_matched_log = optional(object({
      filter           = string
      label_extractors = optional(map(string))
    }))

    # Prometheus condition (PromQL)
    condition_prometheus_query = optional(object({
      query               = string
      duration            = optional(string, "60s")
      evaluation_interval = optional(string, "60s")
      rule_group          = optional(string)
    }))

    documentation = optional(object({
      content   = string
      mime_type = optional(string, "text/markdown")
    }))
  }))
  default = {}
}

variable "dashboards" {
  description = "Map of Cloud Monitoring dashboards to create using JSON definitions."
  type = map(object({
    dashboard_json = string # Full JSON string defining the dashboard layout
  }))
  default = {}
}

variable "metric_descriptors" {
  description = "Map of custom metric descriptors to create."
  type = map(object({
    metric_kind = string # "GAUGE", "DELTA", "CUMULATIVE"
    value_type  = string # "BOOL", "INT64", "DOUBLE", "STRING", "DISTRIBUTION"
    unit        = optional(string, "1")
    description = optional(string)
    labels = optional(list(object({
      key         = string
      value_type  = optional(string, "STRING")
      description = optional(string)
    })), [])
  }))
  default = {}
}

variable "uptime_checks" {
  description = "Map of synthetic Uptime Check configurations."
  type = map(object({
    display_name     = string
    timeout          = optional(string, "10s")
    period           = optional(string, "300s")
    selected_regions = optional(list(string), [])
    http_check = optional(object({
      path           = optional(string, "/")
      port           = optional(number, 443)
      use_ssl        = optional(bool, true)
      validate_ssl   = optional(bool, true)
      request_method = optional(string, "GET")
      headers        = optional(map(string), {})
      auth_info = optional(object({
        username = string
        password = string
      }))
    }))
    tcp_check = optional(object({
      port = number
    }))
    monitored_resource = optional(object({
      type   = string # e.g. "uptime_url", "gce_instance"
      labels = map(string)
    }))
    content_matchers = optional(list(object({
      content = string
      matcher = optional(string, "CONTAINS_STRING")
    })), [])
  }))
  default = {}
}
