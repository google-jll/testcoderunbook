provider "google" {
  project = var.project_id
  region  = var.region
}

# -------------------------------------------------------------------------------------
# Cloud Logging bucket + log scope.
#
# Creates one custom log bucket (with Log Analytics enabled) and a log scope that
# spans the listed projects, so Logs Explorer / Log Analytics can query them together.
# -------------------------------------------------------------------------------------
module "log_bucket" {
  source = "../../modules/log-bucket"

  project_id       = var.project_id
  bucket_id        = var.bucket_id
  location         = var.location
  retention_days   = var.retention_days
  description      = "Example central log bucket"
  enable_analytics = true

  # Speed up queries against a couple of common structured fields.
  index_configs = [
    {
      field_path = "jsonPayload.request.status"
      type       = "INDEX_TYPE_STRING"
    },
  ]

  create_scope         = true
  scope_name           = var.scope_name
  scope_description    = "Example scope spanning one or more projects"
  scope_resource_names = var.scope_resource_names

  # Route the listed projects' logs into the bucket. `sink_filter` is an advanced
  # logs filter that limits what each sink forwards — this example keeps only
  # WARNING-and-above entries and drops the noisy Data Access audit logs. Set it
  # to null to forward everything.
  sink_source_projects = var.sink_source_projects
  sink_filter          = "severity >= \"WARNING\" AND NOT logName:\"cloudaudit.googleapis.com%2Fdata_access\""
}
