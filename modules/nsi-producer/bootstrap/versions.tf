terraform {
  required_version = ">= 1.3, < 2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.54"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
