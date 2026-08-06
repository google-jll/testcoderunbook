variable "project_id" {
  type        = string
  description = "The target GCP Project ID where the network foundation will be created."
}

variable "vpc_name" {
  type        = string
  description = "The name of the Standalone VPC network."
}

variable "region" {
  type        = string
  default     = "us-west1" # Default to primary KSA region for residency compliance
  description = "The regional boundary for the subnets and routing resources."
}

variable "environment" {
  type        = string
  description = "The deployment lifecycle environment (e.g., dev, uat, prod)."
}

# JLL-Specific: NetBox-allocated CIDR blocks for regional subnets
variable "subnet_cidr_dmz" {
  type        = string
  description = "CIDR range for the DMZ / Load Balancer Proxy Subnet Tier."
}

variable "subnet_cidr_app" {
  type        = string
  description = "CIDR range for the Application / Workload Subnet Tier."
}

variable "subnet_cidr_data" {
  type        = string
  description = "CIDR range for the Database / Private PSC Endpoints Subnet Tier."
}

variable "enable_internet_egress_route" {
  type        = bool
  default     = false
  description = "Controls whether a route to the internet is natively exposed in this VPC."
}

variable "delete_default_internet_route" {
  type        = bool
  default     = true
  description = "If true, deletes the auto-created 0.0.0.0/0 default route via the default internet gateway."
}