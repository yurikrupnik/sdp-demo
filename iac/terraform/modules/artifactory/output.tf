
output "dockerRepo"{
  value="${google_artifact_registry_repository.docker-repo.location}-docker.pkg.dev/${google_artifact_registry_repository.docker-repo.project}/${google_artifact_registry_repository.docker-repo.repository_id}"
}

