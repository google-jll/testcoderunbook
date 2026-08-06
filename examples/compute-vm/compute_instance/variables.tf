variable "project_id" {
  description = "The GCP project to create the resources in."
  type        = string
}

variable "region" {
  description = "The GCP region for the network and instances."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for the zonal instances and disks."
  type        = string
  default     = "us-central1-b"
}

variable "num_instances" {
  description = "Number of managed instances to create from the template."
  type        = number
  default     = 1
}

variable "service_account" {
  description = "Service account to attach to the templated instances. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account."
  type = object({
    email  = string
    scopes = set(string)
  })
  default = null
}

variable "nat_ip" {
  description = "Optional external IP to assign to the managed instances. Null lets GCP assign an ephemeral IP."
  type        = string
  default     = null
}

variable "network_tier" {
  description = "Network tier for the managed instances' external IP."
  type        = string
  default     = "PREMIUM"
}
