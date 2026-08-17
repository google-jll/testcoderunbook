variable "spoke_project_id" {
  description = "The GCP project ID where the spoke VPC and spoke resource will be created."
  type        = string
}

variable "hub_project_id" {
  description = "The GCP project ID where the pre-existing NCC Mesh Hub resides (optional if ncc_hub_id is provided)."
  type        = string
  default     = null
}

variable "ncc_hub_name" {
  description = "Name of the existing NCC Mesh Hub (optional if ncc_hub_id is provided)."
  type        = string
  default     = "corp-mesh-hub"
}

variable "ncc_hub_id" {
  description = "Direct Resource URI/ID of the existing NCC Hub (e.g. projects/<hub-proj>/locations/global/hubs/<hub-name>). If null, constructed from hub_project_id and ncc_hub_name."
  type        = string
  default     = null
}

variable "spoke_name" {
  description = "Name for the spoke resource attached to the hub."
  type        = string
  default     = "workload-app-spoke"
}

variable "spoke_vpc_name" {
  description = "Name of the spoke VPC network to create and attach."
  type        = string
  default     = "workload-app-vpc"
}

variable "environment" {
  description = "Environment identifier (e.g. dev, uat, prod)."
  type        = string
  default     = "prod"
}

variable "region" {
  description = "GCP region for the spoke VPC subnets."
  type        = string
  default     = "us-central1"
}

variable "subnet_cidr_dmz" {
  description = "CIDR block for the DMZ subnet."
  type        = string
  default     = "10.120.0.0/24"
}

variable "subnet_cidr_app" {
  description = "CIDR block for the Application subnet."
  type        = string
  default     = "10.120.1.0/24"
}

variable "subnet_cidr_data" {
  description = "CIDR block for the Data subnet."
  type        = string
  default     = "10.120.2.0/24"
}
