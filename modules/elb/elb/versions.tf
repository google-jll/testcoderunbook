terraform {
  required_version = ">= 1.3"
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0, < 8"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
  }


}
