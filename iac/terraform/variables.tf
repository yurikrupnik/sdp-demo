variable "project_id" {
  type = string  
  default = "sdp-demo-388112"
}
variable "repository_id" {
  type = string  
  default = "oded-container-repository"
}
variable "location" {
  type = string  
  default = "europe-central2"
}
variable "enable" {
  description = "Actually enable the APIs listed"
  default     = true
}

variable "repo_names" {
  type    = list(string)
  default = ["yurikrupnik/sdp-demo"]
}