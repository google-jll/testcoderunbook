provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# -------------------------------------------------------------------------------------
# 1. VPC Network & Subnetwork
# -------------------------------------------------------------------------------------
module "vpc" {
  source      = "../../modules/vpc"
  project_id  = var.project_id
  name        = var.network_name
  description = "VPC network for Global External Load Balancer with Flex MIG and NSI Consumer"

  subnets = {
    "${var.subnet_name}" = {
      region                   = var.region
      ip_cidr_range            = var.subnet_cidr
      description              = "Private subnet hosting MIG web workload instances"
      private_ip_google_access = true
      secondary_ip_ranges      = []
    }
  }
}

# -------------------------------------------------------------------------------------
# 2. Cloud Router & Cloud NAT (Enables outbound internet access for private MIG instances)
# -------------------------------------------------------------------------------------
module "cloud_router" {
  source     = "../../modules/cloud-router"
  project_id = var.project_id
  region     = var.region
  name       = "${var.network_name}-router"
  network    = module.vpc.network_name
}

module "cloud_nat" {
  source                             = "../../modules/cloud-nat"
  project_id                         = var.project_id
  region                             = var.region
  name                               = "${var.network_name}-nat"
  router                             = module.cloud_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# -------------------------------------------------------------------------------------
# 3. Secure Tags Provisioning (Zero-Trust Identity Tags for GCE Instances & Firewall Policies)
#    NOTE: For VPC Firewall Policies, Tag Keys MUST specify purpose = "GCE_FIREWALL"
#          and purpose_data = { network = "<project_id>/<network_name>" }.
# -------------------------------------------------------------------------------------
module "secure_tags" {
  source = "../../modules/secure-tags"
  parent = "projects/${var.project_id}"

  keys = {
    "${var.tag_key_name}" = {
      description  = "Environment secure tag key for MIG web node classification"
      purpose      = "GCE_FIREWALL"
      purpose_data = {
        network = "${var.project_id}/${var.network_name}"
      }
      values = {
        "${var.tag_value_name}" = {
          description = "Secure tag value assigned to Web MIG & Flex MIG instances"
        }
      }
    }
  }

  depends_on = [module.vpc]
}

# -------------------------------------------------------------------------------------
# 4. NSI Consumer Module (Network Service Integration Intercept + Firewall Policy)
#  - Connects to Palo Alto deployment group "testjll-panw-dg" in project "jllnetworkhub"
#  - Steers traffic from whitelisted IP ranges and Load Balancer proxies through NSI Producer
#  - Applies custom rules matching target_secure_tags for GCE instances
# -------------------------------------------------------------------------------------
module "nsi_consumer" {
  source     = "../../modules/nsi-consumer"
  project_id = var.project_id
  org_id     = var.org_id
  prefix     = var.network_name
  network_id = module.vpc.network_id

  # Palo Alto / NSI Producer Deployment Group in project jllnetworkhub
  producer_dg          = var.producer_dg
  mirroring_deployment = false

  # Steer traffic from whitelisted source IPs and Load Balancer probe CIDRs through NSI Intercept
  inspect_ranges = concat(var.allowed_ip_ranges, ["130.211.0.0/22", "35.191.0.0/16"])

  # Pass custom rules targeting GCE instances via Secure Tags to NSI Consumer's internal firewall policy
  rules = {
    "allow-whitelisted-ips" = {
      priority           = 999
      direction          = "INGRESS"
      action             = "allow"
      description        = "Allow whitelisted source IPs (allowed_ip_ranges) to reach instances with Secure Tag on HTTP port 80"
      target_secure_tags = [module.secure_tags.values["${var.tag_key_name}/${var.tag_value_name}"]]
      match = {
        src_ip_ranges  = var.allowed_ip_ranges
        layer4_configs = [{ ip_protocol = "tcp", ports = ["80"] }]
      }
    },
    "allow-lb-healthchecks" = {
      priority           = 1000
      direction          = "INGRESS"
      action             = "allow"
      description        = "Allow GCP Global Load Balancer probes (130.211.0.0/22 & 35.191.0.0/16) to reach instances with Secure Tag on HTTP port 80"
      target_secure_tags = [module.secure_tags.values["${var.tag_key_name}/${var.tag_value_name}"]]
      match = {
        src_ip_ranges  = ["130.211.0.0/22", "35.191.0.0/16"]
        layer4_configs = [{ ip_protocol = "tcp", ports = ["80"] }]
      }
    },
    "allow-iap-ssh" = {
      priority           = 1001
      direction          = "INGRESS"
      action             = "allow"
      description        = "Allow IAP SSH (35.235.240.0/20) to reach instances with Secure Tag on port 22"
      target_secure_tags = [module.secure_tags.values["${var.tag_key_name}/${var.tag_value_name}"]]
      match = {
        src_ip_ranges  = ["35.235.240.0/20"]
        layer4_configs = [{ ip_protocol = "tcp", ports = ["22"] }]
      }
    }
  }

  depends_on = [module.secure_tags]
}

# -------------------------------------------------------------------------------------
# 5. Cloud Armor Security Policy (Allow Whitelisted IP ranges, Drop all other traffic with 403)
# -------------------------------------------------------------------------------------
module "cloud_armor" {
  source            = "../../modules/cloud-armor"
  project_id        = var.project_id
  policy_name       = var.cloud_armor_policy_name
  allowed_ip_ranges = var.allowed_ip_ranges
}

# -------------------------------------------------------------------------------------
# 6. Compute Instance Template (Attaches Secure Tags to GCE Instances via resource_manager_tags)
# -------------------------------------------------------------------------------------
module "instance_template" {
  source       = "../../modules/compute-vm/instance_template"
  project_id   = var.project_id
  region       = var.region
  name_prefix  = "${var.mig_name}-template"
  machine_type = var.default_machine_type

  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets["${var.subnet_name}"].id

  # Attach Secure Tag to template so every MIG instance inherits tag for Firewall Policy targeting
  resource_manager_tags = {
    (module.secure_tags.keys["${var.tag_key_name}"]) = module.secure_tags.values["${var.tag_key_name}/${var.tag_value_name}"]
  }

  startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<h1>Hello from GCP Global ELB + NSI Consumer + Flex MIG ($(hostname))</h1>" > /var/www/html/index.html
    systemctl restart nginx
  EOF

  service_account = {
    email  = null # Default Compute Engine SA
    scopes = ["cloud-platform"]
  }
}

# -------------------------------------------------------------------------------------
# 7. Managed Instance Group (Supports both Standard MIG and Flexible MIG options)
# -------------------------------------------------------------------------------------
module "mig" {
  source                           = "../../modules/compute-vm/mig"
  project_id                       = var.project_id
  region                           = var.region
  hostname                         = var.mig_name
  mig_name                         = var.mig_name
  instance_template                = module.instance_template.self_link
  distribution_policy_target_shape = var.enable_flex_mig ? "ANY" : null

  update_policy = var.enable_flex_mig ? [
    {
      type                         = "OPPORTUNISTIC"
      minimal_action               = "REPLACE"
      instance_redistribution_type = "NONE"
      max_surge_fixed              = 3
      max_unavailable_fixed        = 0
    }
  ] : []

  named_ports = [
    {
      name = "http"
      port = 80
    }
  ]

  instance_selections = var.enable_flex_mig ? var.flex_instance_selections : {}

  health_check = {
    type                = "http"
    port                = 80
    request_path        = "/"
    request             = null
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    initial_delay_sec   = 60
    enable_logging      = true
    host                = null
    response            = null
    proxy_header        = "NONE"
  }

  autoscaling_enabled = true
  min_replicas        = var.min_replicas
  max_replicas        = var.max_replicas
  cooldown_period     = 60
  autoscaling_cpu = [
    {
      target            = 0.70
      predictive_method = "NONE"
    }
  ]
}

# -------------------------------------------------------------------------------------
# 8. Global External HTTP Load Balancer (ELB linked to Cloud Armor & MIG)
# -------------------------------------------------------------------------------------
module "global_elb" {
  source  = "../../modules/elb/elb"
  project = var.project_id
  name    = var.elb_name

  # Health check ingress rules are governed by Network Firewall Policy via nsi_consumer,
  # so disable creation of legacy VPC firewall rules on the non-existent 'default' network.
  firewall_networks = []

  security_policy = module.cloud_armor.policy_self_link

  backends = {
    "web-backend" = {
      description                     = "Global External Load Balancer Backend for Web MIG"
      protocol                        = "HTTP"
      port_name                       = "http"
      timeout_sec                     = 30
      connection_draining_timeout_sec = 30
      enable_cdn                      = false
      security_policy                 = module.cloud_armor.policy_self_link

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = module.mig.instance_group
        }
      ]

      health_check = {
        type                = "http"
        port                = 80
        request_path        = "/"
        check_interval_sec  = 10
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        host                = null
        response            = null
        proxy_header        = "NONE"
        enable_logging      = true
      }
    }
  }
}
