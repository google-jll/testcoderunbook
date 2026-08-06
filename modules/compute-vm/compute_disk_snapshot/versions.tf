terraform {
  required_version = ">=1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.71, < 8"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
  }
}
