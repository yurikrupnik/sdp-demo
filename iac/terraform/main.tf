
#  Activate artifactregistry.googleapis.com api
resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service  = "artifactregistry.googleapis.com"
}

module "artifactRegistery" {
  source = "./modules/artifactory"

  project_id     = var.project_id
  location       = var.location
  repository_id  = var.repository_id
  description    = "example docker repository"
  format         = "DOCKER"

  depends_on = [
    google_project_service.artifactregistry,
  ]
}

#  activate iamcredentials.googleapis.com api
resource "google_project_service" "iam_credentials" {
  project = var.project_id
  service   = "iamcredentials.googleapis.com"
}

module "workloadidentity" {
  source = "./modules/workloadidentity"

  project_id                                    = var.project_id
  location                                      = var.location
  display_name                                  = "Github Pool"
  provider_display_name                         = "Github provider"
  workload_identity_pool_id                     = "github-pool-terraform3"
  workload_identity_pool_description            = "Github Pool Terraform"
  workload_identity_pool_provider_id            = "github-provider-terraform"
  workload_identity_pool__provider_description  = "OIDC identity pool provider for Github"
  service_account_id                            = "container-pusher"
  service_account_display_name                  = "Container Pusher"
  repo_names                                    = var.repo_names

  depends_on = [
    google_project_service.iam_credentials,
  ]
}



