variable "project_id" {
  description = "The GCP project that holds the hub and spoke networks."
  type        = string
}

variable "region" {
  description = "The GCP region for the spoke VPC subnets."
  type        = string
  default     = "us-central1"
}

variable "ncc_hub_name" {
  description = "Name of the NCC hub."
  type        = string
  default     = "example-mesh-hub"
}
