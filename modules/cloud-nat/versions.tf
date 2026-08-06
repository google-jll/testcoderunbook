terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.51, < 8"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
