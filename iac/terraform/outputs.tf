output "dockerRepo" {
  description = "docker repo name"
  value       = module.artifactRegistery.dockerRepo
}
output "workloadName" {
  description = "Pool name"
  value       = module.workloadidentity.workloadName
}
output "workloadSAEmail" {
  description = "service accoount email"
  value       = module.workloadidentity.workloadSAEmail 
}