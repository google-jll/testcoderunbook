# -------------------------------------------------------------------------------------
# 0. Optional: Disable Default Project Sink (_Default)
# -------------------------------------------------------------------------------------
resource "google_logging_project_sink" "default_sink_override" {
  count = (var.disable_default_sink && var.project_id != null) ? 1 : 0

  project     = var.project_id
  name        = "_Default"
  destination = "logging.googleapis.com/projects/${var.project_id}/locations/global/buckets/_Default"
  disabled    = true
}

# -------------------------------------------------------------------------------------
# 1. Project Log Sinks (Router Export to Storage, BigQuery, PubSub, or Regional Log Buckets)
# -------------------------------------------------------------------------------------
resource "google_logging_project_sink" "sinks" {
  for_each = var.log_sinks

  project                = var.project_id
  name                   = each.value.name
  destination            = each.value.destination
  filter                 = each.value.filter
  description            = each.value.description
  disabled               = each.value.disabled
  unique_writer_identity = each.value.unique_writer_identity
  custom_writer_identity = each.value.custom_writer_identity

  dynamic "bigquery_options" {
    for_each = each.value.bigquery_options != null ? [each.value.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions != null ? each.value.exclusions : []
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
      disabled    = exclusions.value.disabled
    }
  }
}

# -------------------------------------------------------------------------------------
# 2. Log-based Metrics (Project Level)
# -------------------------------------------------------------------------------------
resource "google_logging_metric" "metrics" {
  for_each = var.log_metrics

  project          = var.project_id
  name             = each.value.name
  filter           = each.value.filter
  description      = each.value.description
  disabled         = each.value.disabled
  bucket_name      = each.value.bucket_name
  value_extractor  = each.value.value_extractor
  label_extractors = each.value.label_extractors

  dynamic "metric_descriptor" {
    for_each = each.value.metric_descriptor != null ? [each.value.metric_descriptor] : []
    content {
      metric_kind = metric_descriptor.value.metric_kind
      value_type  = metric_descriptor.value.value_type
      unit        = metric_descriptor.value.unit
    }
  }

  dynamic "bucket_options" {
    for_each = each.value.bucket_options != null ? [each.value.bucket_options] : []
    content {
      dynamic "linear_buckets" {
        for_each = bucket_options.value.linear_buckets != null ? [bucket_options.value.linear_buckets] : []
        content {
          num_finite_buckets = linear_buckets.value.num_finite_buckets
          width              = linear_buckets.value.width
          offset             = linear_buckets.value.offset
        }
      }

      dynamic "exponential_buckets" {
        for_each = bucket_options.value.exponential_buckets != null ? [bucket_options.value.exponential_buckets] : []
        content {
          num_finite_buckets = exponential_buckets.value.num_finite_buckets
          growth_factor      = exponential_buckets.value.growth_factor
          scale              = exponential_buckets.value.scale
        }
      }

      dynamic "explicit_buckets" {
        for_each = bucket_options.value.explicit_buckets != null ? [bucket_options.value.explicit_buckets] : []
        content {
          bounds = explicit_buckets.value.bounds
        }
      }
    }
  }
}

# -------------------------------------------------------------------------------------
# 3. Project Log Buckets Config (Global & Custom Regional Log Buckets)
# -------------------------------------------------------------------------------------
resource "google_logging_project_bucket_config" "buckets" {
  for_each = var.log_buckets

  project          = var.project_id
  location         = each.value.location
  bucket_id        = each.value.bucket_id
  retention_days   = each.value.retention_days
  enable_analytics = each.value.enable_analytics
  description      = each.value.description

  dynamic "cmek_settings" {
    for_each = each.value.cmek_settings != null ? [each.value.cmek_settings] : []
    content {
      kms_key_name = cmek_settings.value.kms_key_name
    }
  }

  dynamic "index_configs" {
    for_each = each.value.index_configs != null ? each.value.index_configs : []
    content {
      field_path = index_configs.value.field_path
      type       = index_configs.value.type
    }
  }
}

# -------------------------------------------------------------------------------------
# 4. Project Log Exclusions (Drop unwanted logs before ingestion)
# -------------------------------------------------------------------------------------
resource "google_logging_project_exclusion" "exclusions" {
  for_each = var.log_exclusions

  project     = var.project_id
  name        = each.value.name
  description = each.value.description
  filter      = each.value.filter
  disabled    = each.value.disabled
}

# -------------------------------------------------------------------------------------
# 5. Folder Log Sinks (Aggregated & Intercepted Folder Router Export)
# -------------------------------------------------------------------------------------
resource "google_logging_folder_sink" "folder_sinks" {
  for_each = var.folder_sinks

  folder             = coalesce(each.value.folder_id, var.folder_id)
  name               = each.value.name
  destination        = each.value.destination
  filter             = each.value.filter
  description        = each.value.description
  disabled           = each.value.disabled
  include_children   = each.value.include_children
  intercept_children = each.value.intercept_children

  dynamic "bigquery_options" {
    for_each = each.value.bigquery_options != null ? [each.value.bigquery_options] : []
    content {
      use_partitioned_tables = bigquery_options.value.use_partitioned_tables
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions != null ? each.value.exclusions : []
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
      disabled    = exclusions.value.disabled
    }
  }
}

# -------------------------------------------------------------------------------------
# 6. Folder Log Buckets Config
# -------------------------------------------------------------------------------------
resource "google_logging_folder_bucket_config" "folder_buckets" {
  for_each = var.folder_buckets

  folder         = coalesce(each.value.folder_id, var.folder_id)
  location       = each.value.location
  bucket_id      = each.value.bucket_id
  retention_days = each.value.retention_days
  description    = each.value.description

  dynamic "cmek_settings" {
    for_each = each.value.cmek_settings != null ? [each.value.cmek_settings] : []
    content {
      kms_key_name = cmek_settings.value.kms_key_name
    }
  }

  dynamic "index_configs" {
    for_each = each.value.index_configs != null ? each.value.index_configs : []
    content {
      field_path = index_configs.value.field_path
      type       = index_configs.value.type
    }
  }
}

# -------------------------------------------------------------------------------------
# 7. Folder Log Exclusions
# -------------------------------------------------------------------------------------
resource "google_logging_folder_exclusion" "folder_exclusions" {
  for_each = var.folder_exclusions

  folder      = coalesce(each.value.folder_id, var.folder_id)
  name        = each.value.name
  description = each.value.description
  filter      = each.value.filter
  disabled    = each.value.disabled
}
