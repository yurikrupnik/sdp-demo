
resource "google_iam_workload_identity_pool" "example-pool-terraform" {
  project                   = var.project_id 
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = var.display_name
  description               = var.workload_identity_pool_description
  

}

resource "google_iam_workload_identity_pool_provider" "example" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.example-pool-terraform.workload_identity_pool_id
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
