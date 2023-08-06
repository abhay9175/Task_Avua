variable "dockerhub_username" {
  type = string
  default = ""
}

variable "dockerhub_password" {
  type = string
  default = ""
}

variable "dockerhub_repository" {
  type = string
  default = "new-repo"
}

locals {
  image_tag = "latest"
}
