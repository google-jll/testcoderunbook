/*
 * Combined compute_instance example. Merges the upstream `simple`, `tags`,
 * `next_hop`, `multiple_interfaces`, and `disk_snapshot` examples into one
 * self-contained, deployable configuration:
 *   - an instance template with network tags, IP forwarding, and an extra disk
 *   - managed instances built from that template (with an external IP)
 *   - a standalone multi-NIC instance that also acts as a next hop
 *   - a snapshot schedule policy attached to a set of disks
 */

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

############
# Network
############
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "ci-example-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_a" {
  project       = var.project_id
  name          = "ci-example-subnet-a"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_subnetwork" "subnet_b" {
  project       = var.project_id
  name          = "ci-example-subnet-b"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.20.0/24"
}

###########################################
# Instance template + managed instances
# (from the `simple` + `tags` + `next_hop` examples: network tags and
#  can_ip_forward live on the template; an extra data disk is attached.)
###########################################
module "instance_template" {
  source = "../../../modules/compute-vm/instance_template"

  project_id         = var.project_id
  region             = var.region
  subnetwork         = google_compute_subnetwork.subnet_a.self_link
  subnetwork_project = var.project_id
  service_account    = var.service_account

  name_prefix    = "instance-combined"
  tags           = ["health-check", "ssh"]
  can_ip_forward = true

  additional_disks = [
    {
      auto_delete  = true
      boot         = false
      disk_size_gb = 20
      disk_type    = "pd-standard"
      disk_labels  = { purpose = "data" }
    },
  ]
}

module "compute_instance" {
  source = "../../../modules/compute-vm/compute_instance"

  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  subnetwork          = google_compute_subnetwork.subnet_a.self_link
  subnetwork_project  = var.project_id
  num_instances       = var.num_instances
  hostname            = "instance-simple"
  instance_template   = module.instance_template.self_link
  deletion_protection = false

  access_config = [{
    nat_ip       = var.nat_ip
    network_tier = var.network_tier
  }]
}

###########################################
# Multi-NIC instance that also forwards IP
# (from the `multiple_interfaces` + `next_hop` examples.)
###########################################
resource "google_compute_instance" "multi_nic" {
  project      = var.project_id
  zone         = var.zone
  name         = "instance-multi-nic"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Acts as a next hop for custom routes.
  can_ip_forward = true

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_a.self_link
    network_ip = "10.0.0.14"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_b.self_link
    network_ip = "10.10.20.14"
  }
}

###########################################
# Disk snapshot schedule policy
# (from the `disk_snapshot` example.)
###########################################
resource "google_compute_disk" "snapshot_demo" {
  count   = 2
  project = var.project_id
  name    = "ci-snapshot-demo-${count.index + 1}"
  type    = "pd-standard"
  zone    = var.zone
  size    = 20
}

module "disk_snapshots" {
  source = "../../../modules/compute-vm/compute_disk_snapshot"

  name    = "ci-backup-policy"
  project = var.project_id
  region  = var.region

  snapshot_retention_policy = {
    max_retention_days    = 10
    on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
  }

  snapshot_schedule = {
    daily_schedule = {
      days_in_cycle = 1
      start_time    = "08:00"
    }
    hourly_schedule = null
    weekly_schedule = null
  }

  snapshot_properties = {
    guest_flush       = true
    storage_locations = ["EU"]
    labels            = null
  }

  disks = google_compute_disk.snapshot_demo[*].self_link
}
