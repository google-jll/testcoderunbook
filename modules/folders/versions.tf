terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 8"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
