variable "dockerhub_username" {
  type = string
  default ="username" #fill the username 
}

variable "dockerhub_password" {
  type = string
  default = "password" #Fill the username
}

variable "dockerhub_repository" {
  type = string
  default = "new-repo"
}

locals {
  image_tag = "latest"
}
