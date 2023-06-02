
output "workloadName"{
  value=google_iam_workload_identity_pool_provider.example.name
}

output "workloadSAEmail"{
  value=google_service_account.container-builder-sa.email
}
