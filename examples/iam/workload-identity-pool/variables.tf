variable "project_id" {
  description = "The GCP project ID to deploy the Workload Identity Pool into."
  type        = string
}

variable "pool_id" {
  description = "The ID of the Workload Identity Pool."
  type        = string
  default     = "example-github-pool"
}

variable "github_repo" {
  description = "The GitHub repository in owner/repo format for attribute mapping and IAM binding (e.g. 'my-org/my-repo')."
  type        = string
  default     = "my-org/my-repo"
}

variable "create_service_account" {
  description = "Whether to create a demo Service Account to bind Workload Identity permissions to."
  type        = bool
  default     = true
}

variable "service_account_id" {
  description = "The Service Account ID (e.g. 'github-deployer-sa') to create if create_service_account=true, or an existing service account email if create_service_account=false."
  type        = string
  default     = "github-deployer-sa"
}
