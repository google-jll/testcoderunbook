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

variable "auto_accept_projects" {
  description = "Project IDs (or numbers) whose spokes are automatically accepted into the mesh hub's default group when they attach later."
  type        = list(string)
  default     = []
}
