variable "project_id" {
  description = "Optional. The GCP project ID where Cloud Monitoring resources will be deployed."
  type        = string
  default     = null
}

variable "alert_email" {
  description = "Email address for DevOps notification channel alerts."
  type        = string
  default     = "devops-alerts@example.com"
}

variable "cpu_threshold" {
  description = "CPU utilization threshold value (0.0 to 1.0) for high CPU alert policy."
  type        = number
  default     = 0.85
}

variable "app_hostname" {
  description = "Hostname for synthetic web app uptime check."
  type        = string
  default     = "example.com"
}

variable "enable_notification_channels" {
  description = "Whether to deploy notification channels in this run."
  type        = bool
  default     = true
}

variable "enable_alert_policies" {
  description = "Whether to deploy alert policies in this run."
  type        = bool
  default     = true
}

variable "enable_metric_descriptors" {
  description = "Whether to deploy custom metric descriptors in this run."
  type        = bool
  default     = true
}

variable "enable_dashboards" {
  description = "Whether to deploy custom dashboards in this run."
  type        = bool
  default     = true
}

variable "enable_uptime_checks" {
  description = "Whether to deploy synthetic uptime checks in this run."
  type        = bool
  default     = true
}
