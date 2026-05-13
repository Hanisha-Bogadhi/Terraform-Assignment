variable "region" {
  default = "ap-south-2"
}

variable "backend_image" {}

variable "frontend_image" {}

variable "backend_container_name" {
  default = "backend"
}

variable "frontend_container_name" {
  default = "frontend"
}