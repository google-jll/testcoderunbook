variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for deployment"
}

variable "zones" {
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b"]
  description = "List of GCP zones in the region to distribute Panorama and Firewall instances across"
}

variable "panos_auth_key" {
  type        = string
  description = "Panorama VM Auth Key used to register firewalls"
  sensitive   = true
}

variable "panorama_target_size" {
  type        = number
  default     = 2
  description = "Target number of Panorama instances in the Managed Instance Group"
}

variable "panorama_image_family" {
  type        = string
  default     = "windows-2022"
  description = "Source image family for Panorama instances. Defaults to base Windows image family (windows-2022). Can be set to panorama-byol-102 for Palo Alto."
}

variable "panorama_image_project" {
  type        = string
  default     = "windows-cloud"
  description = "Source image project for Panorama instances. Defaults to windows-cloud. Can be set to paloaltonetworksgcp-public for Palo Alto."
}

variable "fw_image_family" {
  type        = string
  default     = "windows-2022"
  description = "Source image family for VM-Series Firewall instances. Defaults to base Windows image family (windows-2022). Can be set to vmseries-byol-102 for Palo Alto."
}

variable "fw_image_project" {
  type        = string
  default     = "windows-cloud"
  description = "Source image project for VM-Series Firewall instances. Defaults to windows-cloud. Can be set to paloaltonetworksgcp-public for Palo Alto."
}

variable "panorama_machine_type" {
  type        = string
  default     = "n2-standard-16"
  description = "GCP machine type for Panorama instances"
}

variable "fw_machine_type" {
  type        = string
  default     = "n2-standard-4"
  description = "GCP machine type for VM-Series Firewall instances"
}
