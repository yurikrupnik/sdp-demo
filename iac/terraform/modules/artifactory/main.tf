

resource "google_artifact_registry_repository" "docker-registry" {
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format

  docker_config {
    immutable_tags = true
  }
  labels = {
    iac: "terraform"
}
}