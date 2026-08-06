variable "project_id" {
  description = "The ID of the GCP project in which to provision the Cloud Armor policy."
  type        = string
}

variable "policy_name" {
  description = "The name of the Cloud Armor security policy."
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of whitelisted IP ranges isolated as parameterized variables."
  type        = list(string)
}