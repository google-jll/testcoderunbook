terraform {
  required_version = "> 1.5, < 2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.50, < 8"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.50, < 8"
    }
  }
}
