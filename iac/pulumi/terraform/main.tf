
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

resource "google_artifact_registry_repository" "docker-registry" {
  location      = var.location
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

}

resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "example-pool"
}

# resource "google_iam_workload_identity_pool_provider" "example" {
#   workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
#   workload_identity_pool_provider_id = "example-prvdr"
#   display_name                       = "Name of provider"
#   description                        = "OIDC identity pool provider for automated test"
#   disabled                           = true
#   attribute_condition                = "\"e968c2ef-047c-498d-8d79-16ca1b61e77e\" in assertion.groups"
#   attribute_mapping                  = {
#     "google.subject"                  = "\"azure::\" + assertion.tid + \"::\" + assertion.sub"
#     "attribute.tid"                   = "assertion.tid"
#     "attribute.managed_identity_name" = <<EOT
#       {
#         "8bb39bdb-1cc5-4447-b7db-a19e920eb111":"workload1",
#         "55d36609-9bcf-48e0-a366-a3cf19027d2a":"workload2"
#       }[assertion.oid]
# EOT
#   }
#   oidc {
#     allowed_audiences = ["https://example.com/gcp-oidc-federation", "example.com/gcp-oidc-federation"]
#     issuer_uri        = "https://sts.windows.net/azure-tenant-id"
#   }
# }
resource "google_iam_workload_identity_pool_provider" "example" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.example-pool-terraform.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-providerr"
  display_name                       = "Github provider"
  description                        = "OIDC identity pool provider for Github"
  attribute_mapping                  = {
    "google.subject"                 = "assertion.sub"
    "attribute.tid"                  = "assertion.actor"
    "attribute.repository"           = "assertion.repository"
  }
  oidc {
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}




resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.container-builder-sa.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "",
  ]
}