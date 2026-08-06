locals {
  self_links = concat(
    google_compute_health_check.http[*].self_link,
    google_compute_health_check.https[*].self_link,
    google_compute_health_check.tcp[*].self_link,
  )
}

resource "google_compute_health_check" "http" {
  count   = var.type == "http" ? 1 : 0
  project = var.project_id
  name    = var.name

  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  timeout_sec         = var.timeout_sec
  unhealthy_threshold = var.unhealthy_threshold

  http_health_check {
    port         = var.port
    request_path = var.request_path
    host         = var.host
    response     = var.response
    proxy_header = var.proxy_header
  }

  log_config {
    enable = var.enable_logging
  }
}

resource "google_compute_health_check" "https" {
  count   = var.type == "https" ? 1 : 0
  project = var.project_id
  name    = var.name

  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  timeout_sec         = var.timeout_sec
  unhealthy_threshold = var.unhealthy_threshold

  https_health_check {
    port         = var.port
    request_path = var.request_path
    host         = var.host
    response     = var.response
    proxy_header = var.proxy_header
  }

  log_config {
    enable = var.enable_logging
  }
}

resource "google_compute_health_check" "tcp" {
  count   = var.type == "tcp" ? 1 : 0
  project = var.project_id
  name    = var.name

  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  timeout_sec         = var.timeout_sec
  unhealthy_threshold = var.unhealthy_threshold

  tcp_health_check {
    port         = var.port
    request      = var.request
    response     = var.response
    proxy_header = var.proxy_header
  }

  log_config {
    enable = var.enable_logging
  }
}
