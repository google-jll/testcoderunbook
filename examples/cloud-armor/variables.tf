variable "project_id" {
  description = "The target project ID to host the security policy."
  type        = string
}

variable "policy_name" {
  description = "The name of the Cloud Armor security policy."
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of whitelisted IP addresses mapped to Akamai WAF envelopes [4]."
  type        = list(string)
}