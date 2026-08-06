output "notification_channel_ids" {
  description = "IDs of the created notification channels."
  value       = try(module.cloud_monitoring[0].notification_channel_ids, {})
}

output "alert_policy_ids" {
  description = "IDs of the created alert policies."
  value       = try(module.cloud_monitoring[0].alert_policy_ids, {})
}

output "dashboard_ids" {
  description = "IDs of the created custom dashboards."
  value       = try(module.cloud_monitoring[0].dashboard_ids, {})
}

output "metric_descriptors" {
  description = "Created custom metric descriptors."
  value       = try(module.cloud_monitoring[0].metric_descriptors, {})
}

output "uptime_check_ids" {
  description = "IDs of the created synthetic uptime checks."
  value       = try(module.cloud_monitoring[0].uptime_check_ids, {})
}
