variable "projects" {
  description = "Project ids to apply the project-level IAM bindings to."
  type        = list(string)
  default     = []
}

variable "folders" {
  description = "Folder ids to apply the folder-level IAM bindings to, e.g. \"folders/1234567890\"."
  type        = list(string)
  default     = []
}

variable "viewer_members" {
  description = "Members granted the viewer roles (e.g. \"user:alice@example.com\")."
  type        = list(string)
  default     = []
}
