variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "The GCP region to create and test resources in."
  type        = string
  default     = "us-central1"
}

variable "subnetwork" {
  description = "The subnetwork selflink to host the compute instances in."
  type        = string
}

variable "location" {
  description = "Location for the resources (keyring, key, network, etc.)."
  type        = string
  default     = "us"
}

variable "suffix" {
  description = "A suffix to be used as an identifier for resources. (e.g., suffix for KMS Key, Keyring)."
  type        = string
  default     = ""
}

variable "keyring" {
  description = "Keyring name."
  type        = string
}

variable "key" {
  description = "Key name."
  type        = string
}

variable "service_account_roles" {
  description = "Predefined roles for the Service account that will be created for the VM. Remember to follow principles of least privileges with Cloud IAM."
  type        = list(string)
  default     = []
}
