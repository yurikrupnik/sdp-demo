provider "google" {
  project     = var.project_id
  region      = var.location
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.85.0"
    }
  }
}
