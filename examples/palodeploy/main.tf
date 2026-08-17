provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ------------------------------------------------------------------------------
# 1. NETWORKING (Mgmt, Trust, Untrust VPCs)
#    Utilizing existing foundation `modules/vpc` for VPC & subnet provisioning.
#    `network_firewall_policy_enforcement_order` is set to "BEFORE_CLASSIC_FIREWALL"
#    so network firewall policies take evaluation precedence over classic firewall rules.
# ------------------------------------------------------------------------------

# Management VPC
module "mgmt_vpc" {
  source = "../../modules/vpc"

  project_id                                 = var.project_id
  name                                       = "fw-mgmt-vpc"
  auto_create_subnetworks                    = false
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"

  subnets = {
    "fw-mgmt-subnet" = {
      region        = var.region
      ip_cidr_range = "10.10.10.0/24"
    }
  }
}

# Trust VPC
module "trust_vpc" {
  source = "../../modules/vpc"

  project_id                                 = var.project_id
  name                                       = "fw-trust-vpc"
  auto_create_subnetworks                    = false
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"

  subnets = {
    "fw-trust-subnet" = {
      region        = var.region
      ip_cidr_range = "10.20.10.0/24"
    }
  }
}

# Untrust VPC
module "untrust_vpc" {
  source = "../../modules/vpc"

  project_id                                 = var.project_id
  name                                       = "fw-untrust-vpc"
  auto_create_subnetworks                    = false
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"

  subnets = {
    "fw-untrust-subnet" = {
      region        = var.region
      ip_cidr_range = "10.30.10.0/24"
    }
  }
}

# Network Firewall Policy for Management VPC access
# Utilizing existing foundation `modules/firewall-policy` to create network firewall policy.
module "mgmt_firewall_policy" {
  source = "../../modules/firewall-policy"

  project_id  = var.project_id
  name        = "fw-mgmt-firewall-policy"
  description = "Network firewall policy for Management VPC access"
  network_id  = module.mgmt_vpc.network_id

  rules = {
    "allow-mgmt-ingress" = {
      priority    = 1000
      direction   = "INGRESS"
      action      = "allow"
      description = "Allow SSH, HTTPS, and Panorama communication to Management VPC"
      match = {
        src_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = [
          {
            ip_protocol = "tcp"
            ports       = ["22", "443", "3978", "28443"] # SSH, HTTPS, and Panorama communication
          }
        ]
      }
    }
  }
}

# ------------------------------------------------------------------------------
# 2. PANORAMA MANAGED INSTANCE GROUP (Regional MIG across 2 zones)
#    Utilizing `modules/compute-vm/instance_template` and `modules/compute-vm/mig`.
# ------------------------------------------------------------------------------

# Service account for Panorama
module "panorama_sa" {
  source = "../../modules/iam/service-account"

  project_id   = var.project_id
  account_id   = "panorama-sa"
  display_name = "Panorama Service Account"
}

# Panorama Instance Template
module "panorama_template" {
  source = "../../modules/compute-vm/instance_template"

  project_id           = var.project_id
  region               = var.region
  name_prefix          = "panorama-template"
  machine_type         = var.panorama_machine_type
  source_image_family  = var.panorama_image_family
  source_image_project = var.panorama_image_project
  subnetwork           = module.mgmt_vpc.subnets["fw-mgmt-subnet"].id

  service_account = {
    email  = module.panorama_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Panorama Regional Managed Instance Group (Spun up across 2 zones in the region)
module "panorama_mig" {
  source = "../../modules/compute-vm/mig"

  project_id                = var.project_id
  region                    = var.region
  hostname                  = "panorama"
  mig_name                  = "panorama-mig"
  instance_template         = module.panorama_template.self_link
  target_size               = var.panorama_target_size
  distribution_policy_zones = var.zones
}

# Query regional instance group for instances created by module.panorama_mig
data "google_compute_region_instance_group" "panorama_ig" {
  self_link = module.panorama_mig.instance_group
}

# Query GCE instance details to fetch network interface IPs
data "google_compute_instance" "panorama_instances" {
  count     = var.panorama_target_size
  self_link = tolist(data.google_compute_region_instance_group.panorama_ig.instances)[count.index].instance
}

# ------------------------------------------------------------------------------
# 3. PALO ALTO VM-SERIES FIREWALL MANAGED INSTANCE GROUP (Regional MIG across 2 zones)
#    Utilizing `modules/compute-vm/instance_template` and `modules/compute-vm/mig`.
#    Panorama IPs are dynamically referenced from GCE instances created in panorama_mig.
# ------------------------------------------------------------------------------

# Service account for VM-Series
module "fw_sa" {
  source = "../../modules/iam/service-account"

  project_id   = var.project_id
  account_id   = "vmseries-sa"
  display_name = "VM-Series Service Account"
}

# VM-Series Firewall Instance Template
module "fw_template" {
  source = "../../modules/compute-vm/instance_template"

  project_id           = var.project_id
  region               = var.region
  name_prefix          = "vmseries-template"
  machine_type         = var.fw_machine_type
  source_image_family  = var.fw_image_family
  source_image_project = var.fw_image_project
  can_ip_forward       = "true"

  # nic0: Management (Mandatory first interface in GCP)
  subnetwork = module.mgmt_vpc.subnets["fw-mgmt-subnet"].id

  # nic1: Untrust, nic2: Trust
  additional_networks = [
    {
      subnetwork = module.untrust_vpc.subnets["fw-untrust-subnet"].id
    },
    {
      subnetwork = module.trust_vpc.subnets["fw-trust-subnet"].id
    }
  ]

  # Metadata dynamically referencing GCE instance IP outputs from module.panorama_mig
  metadata = {
    init-cfg-txt = join("\n", [
      "type=dhcp-client",
      "panorama-server=${try(data.google_compute_instance.panorama_instances[0].network_interface[0].network_ip, "")}",
      "panorama-server-2=${try(data.google_compute_instance.panorama_instances[1].network_interface[0].network_ip, try(data.google_compute_instance.panorama_instances[0].network_interface[0].network_ip, ""))}",
      "tplname=Stack-GCP",
      "dgname=DG-GCP",
      "vm-auth-key=${var.panos_auth_key}",
      "op-command-modes=mgmt-dhcp-secure"
    ])

    environment = "production"
    owner       = "secops"
  }

  service_account = {
    email  = module.fw_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# VM-Series Firewall Regional Managed Instance Group (Spun up across 2 zones in the region)
module "fw_mig" {
  source = "../../modules/compute-vm/mig"

  project_id                = var.project_id
  region                    = var.region
  hostname                  = "pa-fw"
  mig_name                  = "pa-fw-mig"
  instance_template         = module.fw_template.self_link
  target_size               = 2
  distribution_policy_zones = var.zones

  depends_on = [
    module.panorama_mig
  ]
}
