
resource "random_id" "bucket_prefix" {
  byte_length = 8
}
resource "google_storage_bucket" "tfstate" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "EU"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_artifact_registry_repository" "docker-registry" {
  location      = "europe-central2"
  repository_id = "docker-registry"
  description   = "example docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
  labels = {
    iac: "terraform"
}
}

resource "google_service_account" "container-builder-sa" {
  account_id    = "container-builder-sa"
  display_name  = "Container builder"
  description   = "Github actions service account to create containers"

}
resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"

  members = [
    "serviceAccount:${google_service_account.container-builder-sa.email}",
  ]

#   condition {

#   }
}




# resource "google_iam_workload_identity_pool" "example" {
#   workload_identity_pool_id = "example-pool"
#   display_name              = "Name of pool"
#   description               = "Identity pool for automated test"
#   disabled                  = true
# }
