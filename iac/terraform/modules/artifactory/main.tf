

resource "google_artifact_registry_repository" "docker-repo" {
  location      = var.location
  repository_id = var.repository_id
  project       = var.project_id
  description   = var.description
  format        = var.format
  mode          = "STANDARD_REPOSITORY"

  docker_config {
    immutable_tags = true
  }
  labels = {
    iac: "terraform"
}
}