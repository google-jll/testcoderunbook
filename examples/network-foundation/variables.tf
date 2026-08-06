variable "project_id" {
  type        = string
  description = "The target GCP Project ID."
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC."
}

variable "environment" {
  type        = string
  description = "Workload environment lifecycle stage (e.g., dev, uat, prod)."
}

variable "region" {
  type        = string
  default     = "us-west1"
  description = "The primary region for deployment."
}

variable "subnet_cidr_dmz" {
  type        = string
  description = "CIDR range for the DMZ / Load Balancer Proxy Subnet Tier."
}

variable "subnet_cidr_app" {
  type        = string
  description = "CIDR range for the App Instances Subnet Tier."
}

variable "subnet_cidr_data" {
  type        = string
  description = "CIDR range for the Data Subnet Tier."
}