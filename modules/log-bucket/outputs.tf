output "bucket_id" {
  description = "The bucket_id of the log bucket."
  value       = google_logging_project_bucket_config.this.bucket_id
}

output "bucket_name" {
  description = "The full resource name of the log bucket (projects/<id>/locations/<loc>/buckets/<bucket_id>)."
  value       = google_logging_project_bucket_config.this.id
}

output "location" {
  description = "The location of the log bucket."
  value       = google_logging_project_bucket_config.this.location
}

output "scope_id" {
  description = "The full resource id of the log scope, or null when create_scope is false."
  value       = one(google_logging_log_scope.this[*].id)
}

output "scope_resource_names" {
  description = "The resources spanned by the log scope, or null when create_scope is false."
  value       = one(google_logging_log_scope.this[*].resource_names)
}

output "sink_writer_identities" {
  description = "Map of source project => the sink's writer identity (granted bucketWriter on the bucket's project)."
  value       = { for k, s in google_logging_project_sink.this : k => s.writer_identity }
}
