output "sink_writer_identities" {
  description = "Service account writer identities for created project log sinks."
  value       = try(module.cloud_logging_project[0].sink_writer_identities, {})
}

output "log_metrics" {
  description = "Created project log-based metric objects."
  value       = try(module.cloud_logging_project[0].log_metrics, {})
}

output "log_buckets" {
  description = "Configured project log bucket details."
  value       = try(module.cloud_logging_project[0].log_buckets, {})
}

output "log_exclusions" {
  description = "Created project log exclusion objects."
  value       = try(module.cloud_logging_project[0].log_exclusions, {})
}

output "default_sink_disabled" {
  description = "Boolean indicating whether the default _Default sink was disabled."
  value       = try(module.cloud_logging_project[0].default_sink_disabled, false)
}

output "folder_sinks" {
  description = "Created folder-level log sink objects (when folder_id is supplied)."
  value       = try(module.cloud_logging_folder[0].folder_sinks, {})
}

output "folder_sink_writer_identities" {
  description = "Writer identities for folder-level log sinks (when folder_id is supplied)."
  value       = try(module.cloud_logging_folder[0].folder_sink_writer_identities, {})
}

output "folder_buckets" {
  description = "Created folder-level log bucket details (when folder_id is supplied)."
  value       = try(module.cloud_logging_folder[0].folder_buckets, {})
}

output "folder_exclusions" {
  description = "Created folder-level log exclusion objects (when folder_id is supplied)."
  value       = try(module.cloud_logging_folder[0].folder_exclusions, {})
}
