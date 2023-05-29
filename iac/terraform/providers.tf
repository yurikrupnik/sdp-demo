provider "google" {
  credentials = file("path/to/your/service-account-key.json")
  project     = var.project_id
  region      = var.location
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