variable "project_id" {
  description = "The ID of the GCP project where KMS resources are provisioned."
  type        = string
}

variable "location" {
  description = "The region or location for the Cloud KMS Key Ring (e.g. 'us-central1', 'global', 'europe-west1')."
  type        = string
  default     = "us-central1"
}

variable "keyring" {
  description = "The name of the Cloud KMS Key Ring."
  type        = string
  default     = "example-keyring"
}
