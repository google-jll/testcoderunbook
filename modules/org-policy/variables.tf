variable "parent" {
  description = "The parent resource URI where policies will be attached. Format: 'organizations/123456789012', 'folders/123456789012', or 'projects/my-project-id'."
  type        = string
}

variable "boolean_policies" {
  description = "Map of Boolean Org Policies to enforce (true) or disable (false). Key is constraint name (e.g. 'constraints/compute.requireShieldedVm')."
  type = map(object({
    enforce             = bool # true to enforce, false to disable/allow
    inherit_from_parent = optional(bool, false)
    reset               = optional(bool, false)
  }))
  default = {}
}

variable "list_policies" {
  description = "Map of List Org Policies to configure. Key is constraint name (e.g. 'constraints/gcp.resourceLocations')."
  type = map(object({
    allow               = optional(list(string)) # List of allowed values
    deny                = optional(list(string)) # List of denied values
    allow_all           = optional(bool)         # Allow all values
    deny_all            = optional(bool)         # Deny all values
    inherit_from_parent = optional(bool, false)
    reset               = optional(bool, false)
  }))
  default = {}
}
