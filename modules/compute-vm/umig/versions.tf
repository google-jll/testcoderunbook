terraform {
  required_version = ">=1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.88, < 8"
    }
  }
}