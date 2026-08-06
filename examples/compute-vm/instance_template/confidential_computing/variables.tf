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

variable "service_account" {
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account."
  type = object({
    email  = string,
    scopes = set(string)
  })
  default = null
}
