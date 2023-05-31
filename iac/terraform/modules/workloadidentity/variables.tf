variable "project_id" {
  type = string  
  default = ""
}
variable "location" {
  type = string  
  default = ""
}
variable "display_name" {
  type = string  
  default = ""
}
variable "service_account_id" {
  type = string  
  default = ""
}
variable "service_account_display_name" {
  type = string  
  default = ""
}
variable "provider_display_name" {
  type = string  
  default = ""
}
variable "workload_identity_pool_id" {
  type = string  
  default = ""
}
variable "workload_identity_pool_description" {
  type = string  
  default = ""
}
variable "workload_identity_pool_provider_id" {
  type = string  
  default = ""
}

variable "workload_identity_pool__provider_description" {
  type = string  
  default = ""
}
variable "repo_names" {
  type    = list(string)
  default = []
}


