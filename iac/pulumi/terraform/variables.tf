variable "project_id" {
  type = string  
  default = "oded-rafi-sandbox"
}
variable "location" {
  type = string  
  default = "europe-central2"
}
variable "enable" {
  description = "Actually enable the APIs listed"
  default     = true
}