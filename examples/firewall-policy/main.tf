provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

locals {
  tag_parent = var.parent != null ? var.parent : "projects/${var.project_id}"
}

# -------------------------------------------------------------------------------------
# 1. VPC Network & Subnet
# -------------------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  name                            = var.network_name
  project                         = var.project_id
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.network_name}-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

# -------------------------------------------------------------------------------------
# 2. Google Cloud Secure Tags (Resource Manager Tags) Module
#    NOTE: For VPC Firewall Policies, Tag Keys MUST specify:
#      purpose      = "GCE_FIREWALL"
#      purpose_data = { network = "<project_id>/<network_name>" }
# -------------------------------------------------------------------------------------
module "secure_tags" {
  source = "../../modules/secure-tags"

  parent = local.tag_parent

  keys = {
    "app-tier" = {
      description  = "Application security tier for firewall policies"
      purpose      = "GCE_FIREWALL"
      purpose_data = {
        network = "${var.project_id}/${var.network_name}"
      }
      values = {
        "app1"     = { description = "App1 workload tier" }
        "app2"     = { description = "App2 workload tier" }
        "database" = { description = "Database backend tier" }
      }
    }
  }

  depends_on = [google_compute_network.vpc]
}

# -------------------------------------------------------------------------------------
# 3. Workload Service Accounts
# -------------------------------------------------------------------------------------
resource "google_service_account" "app1_sa" {
  account_id   = "app1-workload-sa"
  display_name = "App1 Workload Service Account"
  project      = var.project_id
}

resource "google_service_account" "app2_sa" {
  account_id   = "app2-workload-sa"
  display_name = "App2 Workload Service Account"
  project      = var.project_id
}

# -------------------------------------------------------------------------------------
# 4. Workload Compute Engine VM Instances
# -------------------------------------------------------------------------------------
resource "google_compute_instance" "app1_vm" {
  name         = "vm-app1-workload"
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
  }

  service_account {
    email  = google_service_account.app1_sa.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "app2_vm" {
  name         = "vm-app2-workload"
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
  }

  service_account {
    email  = google_service_account.app2_sa.email
    scopes = ["cloud-platform"]
  }
}

# -------------------------------------------------------------------------------------
# 5. Location Tag Bindings: Attach Secure Tags to Zonal Compute Engine VM Instances
#    NOTE: VM instances are zonal resources, so google_tags_location_tag_binding
#    with location = var.zone is required by the Resource Manager API.
# -------------------------------------------------------------------------------------
resource "google_tags_location_tag_binding" "app1_binding" {
  count     = var.create_tag_bindings ? 1 : 0
  parent    = "//compute.googleapis.com/projects/${var.project_id}/zones/${var.zone}/instances/${google_compute_instance.app1_vm.instance_id}"
  tag_value = module.secure_tags.values_by_key["app-tier"]["app1"]
  location  = var.zone
}

resource "google_tags_location_tag_binding" "app2_binding" {
  count     = var.create_tag_bindings ? 1 : 0
  parent    = "//compute.googleapis.com/projects/${var.project_id}/zones/${var.zone}/instances/${google_compute_instance.app2_vm.instance_id}"
  tag_value = module.secure_tags.values_by_key["app-tier"]["app2"]
  location  = var.zone
}

# -------------------------------------------------------------------------------------
# 6. Network Firewall Policy Module (Invoking modules/firewall-policy)
#    Demonstrating all target types, rule actions, directions, secure tags, and optional NSI Intercept.
# -------------------------------------------------------------------------------------
module "firewall_policy" {
  source = "../../modules/firewall-policy"

  project_id             = var.project_id
  name                   = "fw-policy-secure-tags-demo"
  description            = "Network firewall policy demonstrating all target types, rule actions, and NSI steering"
  network_id             = google_compute_network.vpc.id
  security_profile_group = var.security_profile_group
  create_profile_rules   = var.create_profile_rules

  rules = {
    # ---------------------------------------------------------------------------------
    # USECASE 1: "Apply to All" — Baseline internal/SD-WAN egress across entire VPC
    # Action: allow | Direction: EGRESS | Target: None (All instances)
    # ---------------------------------------------------------------------------------
    "egress-sdwan-all" = {
      priority    = 1000
      direction   = "EGRESS"
      action      = "allow"
      description = "USECASE 1: Apply to All - Allow egress to internal SD-WAN subnet"
      match = {
        dest_ip_ranges = ["10.200.0.0/16"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["80", "443"]
        }]
      }
    }

    # ---------------------------------------------------------------------------------
    # USECASE 2: "Service Account Target" — Workload SA egress
    # Action: allow | Direction: EGRESS | Target: Service Account
    # ---------------------------------------------------------------------------------
    "egress-app1-sa" = {
      priority                = 1010
      direction               = "EGRESS"
      action                  = "allow"
      description             = "USECASE 2: Service Account Target - Allow egress for App1 SA workloads"
      target_service_accounts = [google_service_account.app1_sa.email]
      match = {
        dest_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["443"]
        }]
      }
    }

    # ---------------------------------------------------------------------------------
    # USECASE 3: "Target Secure Tag (App1)" — Egress for App1 tagged instances only
    # Action: allow | Direction: EGRESS | Target: Secure Tag (app-tier/app1)
    # ---------------------------------------------------------------------------------
    "egress-app1-secure-tag" = {
      priority           = 1020
      direction          = "EGRESS"
      action             = "allow"
      description        = "USECASE 3: Secure Tag Target - Allow HTTPS egress only for App1 tagged VMs"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"]]
      match = {
        dest_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["443"]
        }]
      }
    }

    # ---------------------------------------------------------------------------------
    # USECASE 4: "Target Secure Tag (App2)" — Egress for App2 tagged instances only
    # Action: allow | Direction: EGRESS | Target: Secure Tag (app-tier/app2)
    # ---------------------------------------------------------------------------------
    "egress-app2-secure-tag" = {
      priority           = 1030
      direction          = "EGRESS"
      action             = "allow"
      description        = "USECASE 4: Secure Tag Target - Allow HTTPS egress only for App2 tagged VMs"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app2"]]
      match = {
        dest_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["443"]
        }]
      }
    }

    # ---------------------------------------------------------------------------------
    # USECASE 5: "Zero-Trust Micro-segmentation" — Ingress from Source Tag to Target Tag
    # Action: allow | Direction: INGRESS | Source: Tag (app1) | Target: Tag (database)
    # ---------------------------------------------------------------------------------
    "ingress-app1-to-database" = {
      priority           = 1040
      direction          = "INGRESS"
      action             = "allow"
      description        = "USECASE 5: Micro-segmentation - Allow App1 tagged VMs to access Database on port 5432"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["database"]]
      match = {
        src_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"]]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["5432"]
        }]
      }
    }

    # ---------------------------------------------------------------------------------
    # USECASE 6: "Explicit Inter-App Isolation" — Ingress Deny from App1 to App2
    # Action: deny | Direction: INGRESS | Source: Tag (app1) | Target: Tag (app2)
    # ---------------------------------------------------------------------------------
    "deny-app1-to-app2-cross-talk" = {
      priority           = 1050
      direction          = "INGRESS"
      action             = "deny"
      description        = "USECASE 6: Isolation - Explicitly deny all traffic from App1 to App2 workloads"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app2"]]
      match = {
        src_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"]]
        layer4_configs = [{
          ip_protocol = "all"
        }]
      }
    }

    # ---------------------------------------------------------------------------------
    # USECASE 7: "Admin Ingress via Google Cloud IAP"
    # Action: allow | Direction: INGRESS | Source: IAP CIDR Range | Target: Secure Tag
    # ---------------------------------------------------------------------------------
    "ingress-admin-iap-ssh" = {
      priority           = 1060
      direction          = "INGRESS"
      action             = "allow"
      description        = "USECASE 7: Admin Ingress - Allow SSH only from Google Cloud IAP IP range"
      target_secure_tags = [module.secure_tags.values_by_key["app-tier"]["app1"], module.secure_tags.values_by_key["app-tier"]["app2"]]
      match = {
        src_ip_ranges = ["35.235.240.0/20"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["22"]
        }]
      }
    }

    # ---------------------------------------------------------------------------------
    # USECASE 8: "Rule Evaluation Chaining with goto_next"
    # Action: goto_next | Direction: INGRESS | Match: Management subnet
    # ---------------------------------------------------------------------------------
    "chain-mgmt-traffic" = {
      priority    = 1070
      direction   = "INGRESS"
      action      = "goto_next"
      description = "USECASE 8: Chaining - Pass internal management traffic to next priority or policy"
      match = {
        src_ip_ranges = ["10.250.0.0/16"]
        layer4_configs = [{
          ip_protocol = "tcp"
          ports       = ["443"]
        }]
      }
    }
  }

  depends_on = [module.secure_tags]
}
