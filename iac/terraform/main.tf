
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

}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.container-builder-sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "",
  ]
}


module "artifactRegistery" {

  source = "./modules/artifactory"

  project_id     = var.project_id
  location       = var.location
  repository_id  = var.repository_id
  description    = "example docker repository"
  format         = "DOCKER"

}


module "workloadidentity" {

  source = "./modules/workloadidentity"

  projectId                                     = var.project_id
  location                                      = var.location
  display_name                                  = "Github Pool"
  provider_display_name                         = "Github provider"
  workload_identity_pool_id                     = "github-pool-te"
  workload_identity_pool_description            = "Github Pool"
  workload_identity_pool_provider_id            = "github-provider"
  workload_identity_pool__provider_description  = "OIDC identity pool provider for Github"

}
