variable "project_id" {
  description = "The GCP project ID where consumer resources will be deployed."
  type        = string
}

variable "org_id" {
  description = "The GCP organization ID (Security profiles/groups are organization-scoped)."
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources (subnets, MIG, Cloud Router, Cloud NAT)."
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = "elb-flex-mig-vpc"
}

variable "subnet_name" {
  description = "Name of the subnetwork."
  type        = string
  default     = "web-mig-subnet"
}

variable "subnet_cidr" {
  description = "IP CIDR range for the subnetwork."
  type        = string
  default     = "10.10.10.0/24"
}

variable "producer_dg" {
  description = "The producer's intercept deployment group URI (Palo Alto NSI producer)."
  type        = string
  default     = "projects/jllnetworkhub/locations/global/interceptDeploymentGroups/testjll-panw-dg"
}

variable "tag_key_name" {
  description = "Short name for the Secure Tag Key."
  type        = string
  default     = "environment"
}

variable "tag_value_name" {
  description = "Short name for the Secure Tag Value."
  type        = string
  default     = "web-mig-node"
}

variable "cloud_armor_policy_name" {
  description = "Name of the Cloud Armor security policy."
  type        = string
  default     = "elb-cloud-armor-allowlist"
}

variable "allowed_ip_ranges" {
  description = "List of whitelisted IPv4 CIDR blocks allowed to access the Load Balancer via Cloud Armor."
  type        = list(string)
  default     = ["203.0.113.0/24", "198.51.100.5/32"] # Example trusted IP ranges
}

variable "elb_name" {
  description = "Name of the Global External Load Balancer."
  type        = string
  default     = "global-web-elb"
}

variable "mig_name" {
  description = "Base name and hostname for the Managed Instance Group."
  type        = string
  default     = "web-app-mig"
}

variable "default_machine_type" {
  description = "Default machine type for the compute instance template."
  type        = string
  default     = "n1-standard-1"
}

variable "enable_flex_mig" {
  description = "Whether to deploy a Flexible Managed Instance Group (Flex MIG) using multiple instance selections/machine types."
  type        = bool
  default     = true
}

variable "flex_instance_selections" {
  description = "Map of flexible instance selections (machine types & ranks) for Flex MIG."
  type = map(object({
    machine_types = list(string)
    rank          = number
  }))
  default = {
    "selection-n1-standard-1" = {
      machine_types = ["n1-standard-1"]
      rank          = 1
    }
    "selection-n2-standard-2" = {
      machine_types = ["n2-standard-2"]
      rank          = 2
    }
    "selection-e2-standard-2" = {
      machine_types = ["e2-standard-2"]
      rank          = 3
    }
  }
}

variable "min_replicas" {
  description = "Minimum number of instances in the MIG autoscaler."
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of instances in the MIG autoscaler."
  type        = number
  default     = 5
}
