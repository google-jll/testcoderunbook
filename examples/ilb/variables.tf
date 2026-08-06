variable "project_id" {
  description = "The GCP project to create the resources in."
  type        = string
}

variable "region" {
  description = "The GCP region for the network, MIG, and internal load balancer."
  type        = string
  default     = "us-central1"
}
