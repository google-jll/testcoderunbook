variable "parent" {
  description = "The parent resource where the tag keys will be created (e.g. 'organizations/123456789012' or 'projects/my-project-id' or 'projects/1234567890')."
  type        = string
}

variable "keys" {
  description = "Map of Tag Keys and their nested Tag Values to create."
  type = map(object({
    description  = optional(string)
    purpose      = optional(string)
    purpose_data = optional(map(string))
    values = optional(map(object({
      description = optional(string)
    })), {})
  }))
  default = {}
}

variable "bindings" {
  description = "Map of Tag Bindings to attach tag values to target resources. Set 'location' for zonal/regional resources (such as Compute Engine VM instances)."
  type = map(object({
    parent       = string           # Full resource URI, e.g., //compute.googleapis.com/projects/...
    location     = optional(string) # Zone or region for zonal/regional resources (e.g. "me-central2-a"). Null for global resources.
    key_name     = optional(string) # Key name declared in var.keys
    val_name     = optional(string) # Value name declared under the key
    tag_value_id = optional(string) # Or direct tag value id: tagValues/1234567890
  }))
  default = {}
}

variable "tag_key_iam_bindings" {
  description = "List of IAM bindings for Tag Keys."
  type = list(object({
    key_name = string
    role     = string
    members  = list(string)
  }))
  default = []
}

variable "tag_value_iam_bindings" {
  description = "List of IAM bindings for Tag Values."
  type = list(object({
    key_name = string
    val_name = string
    role     = string
    members  = list(string)
  }))
  default = []
}
