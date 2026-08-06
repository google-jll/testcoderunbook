output "notification_channels" {
  description = "Map of created notification channel objects."
  value       = google_monitoring_notification_channel.channels
}

output "notification_channel_ids" {
  description = "Map of channel short names to notification channel IDs."
  value       = { for k, v in google_monitoring_notification_channel.channels : k => v.id }
}

output "alert_policies" {
  description = "Map of created alert policy objects."
  value       = google_monitoring_alert_policy.alerts
}

output "alert_policy_ids" {
  description = "Map of alert policy short names to alert policy IDs."
  value       = { for k, v in google_monitoring_alert_policy.alerts : k => v.name }
}

output "dashboards" {
  description = "Map of created dashboard objects."
  value       = google_monitoring_dashboard.dashboards
}

output "dashboard_ids" {
  description = "Map of dashboard short names to dashboard IDs."
  value       = { for k, v in google_monitoring_dashboard.dashboards : k => v.id }
}

output "metric_descriptors" {
  description = "Map of created custom metric descriptors."
  value       = google_monitoring_metric_descriptor.metrics
}

output "uptime_checks" {
  description = "Map of created uptime check configuration objects."
  value       = google_monitoring_uptime_check_config.uptime_checks
}

output "uptime_check_ids" {
  description = "Map of uptime check short names to uptime check IDs."
  value       = { for k, v in google_monitoring_uptime_check_config.uptime_checks : k => v.uptime_check_id }
}
