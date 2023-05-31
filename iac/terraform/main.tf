
# resource "random_id" "bucket_prefix" {
#   byte_length = 8
# }
# resource "google_storage_bucket" "tfstate" {
#   name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
#   force_destroy = false
#   location      = "EU"
#   storage_class = "STANDARD"
#   versioning {
#     enabled = true
#   }
# }
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

  project_id                                    = var.project_id
  location                                      = var.location
  display_name                                  = "oded-Github Pool"
  provider_display_name                         = "oded-Github provider"
  workload_identity_pool_id                     = "oded-github-pool-te"
  workload_identity_pool_description            = "oded-Github Pool"
  workload_identity_pool_provider_id            = "oded-github-provider"
  workload_identity_pool__provider_description  = "OIDC identity pool provider for Github"
  service_account_id                            = "oded-container-builder-sa"
  service_account_display_name                  = "oded-Container builder"
}



