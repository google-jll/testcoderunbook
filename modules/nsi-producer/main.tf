locals {
  prefix = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
  zones  = toset(data.google_compute_zones.available.names)

  # The intercept/mirroring deployment groups store `network` in the short
  # projects/<project>/global/networks/<name> form and force replacement on any
  # textual difference. Normalize whatever the caller passed (full self-link or
  # short form) so importing an existing group is a no-op instead of a replace.
  data_network_normalized = replace(var.data_network_id, "https://www.googleapis.com/compute/v1/", "")
}

# -------------------------------------------------------------------------------------
#  Internal load balancer (health check + backend service).
# -------------------------------------------------------------------------------------

resource "google_compute_region_health_check" "main" {
  name = "${local.prefix}panw-hc"
  https_health_check {
    port         = 443
    request_path = "/unauth/php/health.php"
  }
}

resource "google_compute_region_backend_service" "main" {
  name          = "${local.prefix}panw-lb"
  protocol      = "UDP"
  network       = var.data_network_id
  health_checks = [google_compute_region_health_check.main.self_link]

  backend {
    group          = google_compute_region_instance_group_manager.main.instance_group
    balancing_mode = "CONNECTION"
  }
}

# -------------------------------------------------------------------------------------
#  Firewall service account, instance template, MIG, and autoscaler.
# -------------------------------------------------------------------------------------

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "main" {
  account_id = "${local.prefix}panw-sa"
}

resource "google_project_iam_member" "main" {
  for_each = var.roles
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.main.email}"
}

# Bootstrap bucket that delivers dynamic content/config to the firewalls.
# Local source paths in var.bootstrap_files are relative to this module, so
# prefix them with path.module to keep the module self-contained regardless of
# the working directory Terraform is run from.
module "bootstrap" {
  source          = "./bootstrap"
  location        = "US"
  service_account = google_service_account.main.email
  bucket_name     = var.bootstrap_bucket_name

  files = {
    "${path.module}/bootstrap_files/init-cfg.txt"                         = "config/init-cfg.txt"
    "${path.module}/bootstrap_files/bootstrap.xml"                        = "config/bootstrap.xml"
    "${path.module}/bootstrap_files/authcodes"                            = "license/authcodes"
    "${path.module}/bootstrap_files/panup-all-antivirus-5543-6070"        = "content/panup-all-antivirus-5543-6070"
    "${path.module}/bootstrap_files/panupv2-all-contents-9096-10018"      = "content/panupv2-all-contents-9096-10018"
    "${path.module}/bootstrap_files/panupv3-all-wildfire-1080339-1084680" = "content/panupv3-all-wildfire-1080339-1084680"
  }
}

resource "google_compute_instance_template" "main" {
  name_prefix      = "${local.prefix}panw-template"
  machine_type     = var.machine_type
  min_cpu_platform = "Intel Cascade Lake"
  tags             = ["panw-tutorial"]
  can_ip_forward   = true

  metadata = {
    type                                  = "dhcp-client"
    dhcp-send-client-id                   = "yes"
    dhcp-accept-server-hostname           = "yes"
    dhcp-accept-server-domain             = "yes"
    vm-series-auto-registration-pin-id    = var.csp_pin_id
    vm-series-auto-registration-pin-value = var.csp_pin_value
    authcodes                             = var.csp_authcodes
    dns-primary                           = "169.254.169.254"
    vmseries-bootstrap-gce-storagebucket  = module.bootstrap.bucket_name
  }

  network_interface {
    subnetwork = var.mgmt_subnetwork_id
    dynamic "access_config" {
      for_each = var.mgmt_public_ip ? [1] : []
      content {}
    }
  }

  network_interface {
    subnetwork = var.data_subnetwork_id
  }

  # Optional 3rd (untrust) NIC. Only added when untrust_subnetwork_id is set, so
  # the default 2-NIC (mgmt + data) template is unchanged for existing callers.
  dynamic "network_interface" {
    for_each = var.untrust_subnetwork_id != null ? [1] : []
    content {
      subnetwork = var.untrust_subnetwork_id
    }
  }

  disk {
    source_image = "projects/paloaltonetworksgcp-public/global/images/${var.image_name}"
    disk_type    = "pd-ssd"
    auto_delete  = true
    boot         = true
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    email = google_service_account.main.email
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  depends_on = [module.bootstrap]
}

resource "google_compute_region_instance_group_manager" "main" {
  name                      = "${local.prefix}panw-mig"
  base_instance_name        = "${local.prefix}panw-firewall"
  distribution_policy_zones = data.google_compute_zones.available.names

  version {
    instance_template = google_compute_instance_template.main.id
  }
}

resource "google_compute_region_autoscaler" "main" {
  name   = "${local.prefix}panw-autoscaler"
  target = google_compute_region_instance_group_manager.main.id

  autoscaling_policy {
    min_replicas    = var.min_firewalls
    max_replicas    = var.max_firewalls
    cooldown_period = 480
  }
}

# -------------------------------------------------------------------------------------
#  Forwarding rule per zone within the region.
# -------------------------------------------------------------------------------------

resource "google_compute_forwarding_rule" "main" {
  for_each               = local.zones
  name                   = "${local.prefix}panw-lb-rule-${each.key}"
  project                = var.project_id
  region                 = var.region
  load_balancing_scheme  = "INTERNAL"
  ip_protocol            = "UDP"
  ports                  = ["6081"]
  backend_service        = google_compute_region_backend_service.main.id
  subnetwork             = var.data_subnetwork_id
  network                = var.data_network_id
  is_mirroring_collector = var.mirroring_deployment ? true : false
}

# -------------------------------------------------------------------------------------
#  mirroring_deployment = false -> intercept deployment.
# -------------------------------------------------------------------------------------

resource "google_network_security_intercept_deployment_group" "main" {
  count                         = var.mirroring_deployment ? 0 : 1
  intercept_deployment_group_id = "${local.prefix}panw-dg"
  location                      = "global"
  network                       = local.data_network_normalized
}

resource "google_network_security_intercept_deployment" "main" {
  # Key off the statically-known zone set (not the forwarding-rule resource map)
  # so for_each is determinable at plan/import time; look the rule up by key.
  for_each                   = var.mirroring_deployment ? toset([]) : local.zones
  intercept_deployment_id    = "${local.prefix}panw-deployment-${each.key}"
  location                   = each.key
  forwarding_rule            = google_compute_forwarding_rule.main[each.key].id
  intercept_deployment_group = google_network_security_intercept_deployment_group.main[0].id
}

# -------------------------------------------------------------------------------------
#  mirroring_deployment = true -> mirroring deployment.
# -------------------------------------------------------------------------------------

resource "google_network_security_mirroring_deployment_group" "main" {
  count                         = var.mirroring_deployment ? 1 : 0
  mirroring_deployment_group_id = "${local.prefix}panw-dg"
  location                      = "global"
  network                       = local.data_network_normalized
}

resource "google_network_security_mirroring_deployment" "main" {
  # Key off the statically-known zone set (not the forwarding-rule resource map)
  # so for_each is determinable at plan/import time; look the rule up by key.
  for_each                   = var.mirroring_deployment ? local.zones : toset([])
  mirroring_deployment_id    = "${local.prefix}panw-deployment-${each.key}"
  location                   = each.key
  forwarding_rule            = google_compute_forwarding_rule.main[each.key].id
  mirroring_deployment_group = google_network_security_mirroring_deployment_group.main[0].id
}

# -------------------------------------------------------------------------------------
#  Plain VPC ingress/egress firewall rules. One `firewall` module per entry, each
#  targeting its own network.
# -------------------------------------------------------------------------------------

module "firewall" {
  source   = "../firewall"
  for_each = var.firewall_rules

  project_id    = var.project_id
  network_name  = each.value.network_name
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules
}
