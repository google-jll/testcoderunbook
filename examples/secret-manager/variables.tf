variable "project_id" {
  description = "The ID of the GCP project where Secret Manager resources are provisioned."
  type        = string
}

variable "location" {
  description = "The region or location for the Cloud KMS Key Ring (e.g. 'us-central1', 'global')."
  type        = string
  default     = "us-central1"
}

variable "keyring_name" {
  description = "The name of the Cloud KMS Key Ring used for CMEK."
  type        = string
  default     = "secret-manager-keyring"
}
