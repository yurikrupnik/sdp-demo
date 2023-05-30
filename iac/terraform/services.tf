resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service  = "artifactregistry.googleapis.com"
}
resource "google_project_service" "iam_credentials" {
  project = var.project_id
  service   = "iamcredentials.googleapis.com"
}