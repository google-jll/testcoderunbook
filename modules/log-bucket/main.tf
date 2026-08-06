# ------------------------------------------------------------------------------
# Log bucket — a container for log entries with its own retention and (optionally)
# Log Analytics. Names/locations of the two well-known buckets (_Default,
# _Required) can be adopted in place by passing their bucket_id.
# ------------------------------------------------------------------------------
resource "google_logging_project_bucket_config" "this" {
  project          = var.project_id
  location         = var.location
  bucket_id        = var.bucket_id
  retention_days   = var.retention_days
  description      = var.description
  enable_analytics = var.enable_analytics
  locked           = var.locked
  deletion_policy  = var.deletion_policy

  dynamic "cmek_settings" {
    for_each = var.kms_key_name != null ? [var.kms_key_name] : []
    content {
      kms_key_name = cmek_settings.value
    }
  }

  dynamic "index_configs" {
    for_each = var.index_configs
    content {
      field_path = index_configs.value.field_path
      type       = index_configs.value.type
    }
  }
}

# ------------------------------------------------------------------------------
# Log scope — defines the set of projects and/or log views that are searched
# together in Logs Explorer / Log Analytics. Independent of the bucket above.
# ------------------------------------------------------------------------------
resource "google_logging_log_scope" "this" {
  count = var.create_scope ? 1 : 0

  parent          = "projects/${var.project_id}"
  location        = "global"
  name            = var.scope_name
  resource_names  = var.scope_resource_names
  description     = var.scope_description
  deletion_policy = var.scope_deletion_policy
}

# ------------------------------------------------------------------------------
# Log routing — one sink per source project pointing at the bucket above. The
# destination is derived from the bucket resource, so it always tracks the
# bucket's location.
#
# A sink into a log bucket in ITS OWN project uses the default logging identity:
# writer_identity comes back empty and no extra grant is needed (and forcing a
# unique identity there permadiffs). A CROSS-project sink gets a dedicated writer
# identity that must be granted roles/logging.bucketWriter on the bucket's
# project. So both the unique identity and the grant are cross-project only.
# ------------------------------------------------------------------------------
resource "google_logging_project_sink" "this" {
  for_each = toset(var.sink_source_projects)

  name                   = var.sink_name
  project                = each.value
  destination            = "logging.googleapis.com/${google_logging_project_bucket_config.this.id}"
  filter                 = var.sink_filter
  unique_writer_identity = each.value != var.project_id
}

resource "google_project_iam_member" "bucket_writer" {
  for_each = {
    for proj, sink in google_logging_project_sink.this : proj => sink
    if proj != var.project_id
  }

  project = var.project_id
  role    = "roles/logging.bucketWriter"
  member  = each.value.writer_identity
}
