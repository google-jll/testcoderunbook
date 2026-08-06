variable "project_id" {
  description = "The GCP project ID hosting DNS."
  type        = string
}

variable "vpc_network_self_link" {
  description = "The self_link of the consuming VPC network."
  type        = string
}