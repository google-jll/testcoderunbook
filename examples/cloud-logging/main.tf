provider "google" {
  project = var.project_id
}

# -------------------------------------------------------------------------------------
# 1. Project-Level Cloud Logging Module Invocation (Creates Central Regional Log Bucket & Sinks)
# -------------------------------------------------------------------------------------
module "cloud_logging_project" {
  count  = var.project_id != null ? 1 : 0
  source = "../../modules/cloud-logging"

  project_id           = var.project_id
  disable_default_sink = var.disable_default_sink

  # Custom Regional Log Bucket Configuration (Hosted in Central Logging Project)
  log_buckets = {
    "regional_app_bucket" = {
      location         = var.regional_bucket_location
      bucket_id        = var.regional_bucket_id
      retention_days   = 180
      enable_analytics = true
      description      = "Custom regional log bucket in ${var.regional_bucket_location} for data residency compliance"
      index_configs = [
        {
          field_path = "jsonPayload.user_id"
          type       = "INDEX_TYPE_STRING"
        }
      ]
    }
  }

  # Log Router Sinks (Regional bucket sink is always configured; BigQuery and Cloud Storage sinks are optional)
  log_sinks = merge(
    {
      "regional-logs-to-regional-bucket" = {
        name        = "sink-regional-app-logs"
        destination = "logging.googleapis.com/projects/${var.project_id}/locations/${var.regional_bucket_location}/buckets/${var.regional_bucket_id}"
        filter      = "resource.labels.location=\"${var.regional_bucket_location}\" OR jsonPayload.region=\"${var.regional_bucket_location}\""
        description = "Routes workload logs from ${var.regional_bucket_location} to dedicated regional log bucket"
      }
    },
    var.audit_dataset_id != null ? {
      "audit-logs-to-bigquery" = {
        name        = "sink-audit-logs-bq"
        destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${var.audit_dataset_id}"
        filter      = "logName:\"logs/cloudaudit.googleapis.com\""
        description = "Export security audit logs to BigQuery for SIEM analytics"
        bigquery_options = {
          use_partitioned_tables = true
        }
        exclusions = [
          {
            name        = "exclude-read-operations"
            description = "Exclude noisy object read operations from audit export"
            filter      = "protoPayload.methodName:\"storage.objects.get\""
          }
        ]
      }
    } : {},
    var.archive_bucket_name != null ? {
      "syslog-to-gcs" = {
        name        = "sink-syslog-gcs"
        destination = "storage.googleapis.com/${var.archive_bucket_name}"
        filter      = "resource.type=\"gce_instance\" AND severity>=WARNING"
        description = "Archive GCE warning and error logs to Cloud Storage"
      }
    } : {}
  )

  log_metrics = {
    "ssh_unauthorized_attempts" = {
      name        = "security/ssh_unauthorized_attempts"
      filter      = "resource.type=\"gce_instance\" AND textPayload:\"Permission denied\""
      description = "Log-based metric capturing unauthorized SSH login attempts"
    }

    "gce_error_count" = {
      name        = "compute/gce_error_count"
      filter      = "resource.type=\"gce_instance\" AND severity>=ERROR"
      description = "Log-based metric counting ERROR and CRITICAL level GCE logs"
    }

    "http_response_latency" = {
      name            = "app/http_response_latency"
      filter          = "resource.type=\"http_load_balancer\" AND jsonPayload.latency>0"
      description     = "HTTP load balancer response latency distribution"
      value_extractor = "EXTRACT(jsonPayload.latency)"
      metric_descriptor = {
        metric_kind = "DELTA"
        value_type  = "DISTRIBUTION"
        unit        = "s"
      }
      bucket_options = {
        exponential_buckets = {
          num_finite_buckets = 10
          growth_factor      = 2
          scale              = 0.01
        }
      }
    }
  }

  log_exclusions = {
    "drop_debug_logs" = {
      name        = "exclude-debug-logs"
      filter      = "severity = DEBUG"
      description = "Drop all DEBUG level logs at ingestion to optimize log storage costs"
    }
  }
}

# -------------------------------------------------------------------------------------
# 2. Folder-Level Cloud Logging Module Invocation (Aggregates & Intercepts Child Logs)
# -------------------------------------------------------------------------------------
module "cloud_logging_folder" {
  count  = var.folder_id != null ? 1 : 0
  source = "../../modules/cloud-logging"

  folder_id = var.folder_id

  # Folder Log Sinks (Intercepted folder sinks must route to project destination: logging.googleapis.com/projects/PROJECT_ID)
  folder_sinks = merge(
    var.project_id != null ? {
      "regional-folder-interceptor" = {
        name               = "sink-folder-regional-logs"
        destination        = "logging.googleapis.com/projects/${var.project_id}"
        filter             = "" # Intercepts all logs from child projects
        include_children   = true
        intercept_children = true # Intercepts logs so child project routers do not process them
        description        = "Intercepts and routes all child project logs exclusively into the central project regional log bucket"
      }
    } : {},
    (var.audit_dataset_id != null && var.project_id != null) ? {
      "folder-audit-aggregator" = {
        name               = "sink-folder-audit-logs"
        destination        = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${var.audit_dataset_id}"
        filter             = "logName:\"logs/cloudaudit.googleapis.com\""
        include_children   = true
        intercept_children = false
        description        = "Folder-wide log sink aggregating security audit logs from all child projects"
        bigquery_options = {
          use_partitioned_tables = true
        }
      }
    } : {},
    (var.archive_bucket_name != null) ? {
      "folder-gcs-archive" = {
        name               = "sink-folder-syslog-gcs"
        destination        = "storage.googleapis.com/${var.archive_bucket_name}"
        filter             = "resource.type=\"gce_instance\" AND severity>=WARNING"
        include_children   = true
        intercept_children = false
        description        = "Archive GCE warning/error logs across folder child projects to Cloud Storage"
      }
    } : {}
  )

  depends_on = [module.cloud_logging_project]
}
