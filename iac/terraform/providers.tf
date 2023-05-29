provider "google" {
  credentials = file("path/to/your/service-account-key.json")
  project     = "sdp-demo-388112"
  region      = "europe-central2"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.66.0"
    }
  }

#   required_version = ">= 1.1.0"
}