resource "google_service_account" "container-builder-sa" {
  account_id    = var.service_account_id
  display_name  = var.service_account_display_name
  description   = "Github actions service account to create containers"

}

resource "google_project_iam_binding" "github-sa-artifact-registry-writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"

  members = [
    "serviceAccount:${google_service_account.container-builder-sa.email}",
  ]

}
resource "google_iam_workload_identity_pool" "oded-pool-terraform" {
  project                   = var.project_id 
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = var.display_name
  description               = var.workload_identity_pool_description
  

}

resource "google_iam_workload_identity_pool_provider" "example" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.oded-pool-terraform.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_pool_provider_id
  display_name                       = var.provider_display_name
  description                        = var.workload_identity_pool__provider_description
  attribute_mapping                  = {
    "google.subject"                 = "assertion.sub"
    "attribute.tid"                  = "assertion.actor"
    "attribute.repository"           = "assertion.repository"
  }
  oidc {
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}


locals {
  members = [
    for repo in var.repo_names : "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.oded-pool-terraform.name}/attribute.repository/:${repo}"
  ]
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.container-builder-sa.id
  role               = "roles/iam.workloadIdentityUser"

  members            = local.members
}