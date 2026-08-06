output "sinks" {
  description = "Map of created project log sink objects."
  value       = google_logging_project_sink.sinks
}

output "sink_writer_identities" {
  description = "Map of sink names to generated writer identity service account emails."
  value       = { for k, v in google_logging_project_sink.sinks : k => v.writer_identity }
}

output "log_metrics" {
  description = "Map of created log-based metric objects."
  value       = google_logging_metric.metrics
}

output "log_buckets" {
  description = "Map of created/configured project log bucket objects."
  value       = google_logging_project_bucket_config.buckets
}

output "log_exclusions" {
  description = "Map of created project log exclusion objects."
  value       = google_logging_project_exclusion.exclusions
}

output "default_sink_disabled" {
  description = "Boolean indicating whether the default _Default sink was disabled."
  value       = var.disable_default_sink
}

output "folder_sinks" {
  description = "Map of created folder log sink objects."
  value       = google_logging_folder_sink.folder_sinks
}

output "folder_sink_writer_identities" {
  description = "Map of folder sink names to generated writer identity service account emails."
  value       = { for k, v in google_logging_folder_sink.folder_sinks : k => v.writer_identity }
}

output "folder_buckets" {
  description = "Map of created folder log bucket objects."
  value       = google_logging_folder_bucket_config.folder_buckets
}

output "folder_exclusions" {
  description = "Map of created folder log exclusion objects."
  value       = google_logging_folder_exclusion.folder_exclusions
}
