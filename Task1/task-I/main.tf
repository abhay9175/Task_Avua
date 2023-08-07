terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 2.14.0"
    }
  }
}

resource "null_resource" "docker_login" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker login --username "${var.dockerhub_username}" --password-stdin <<< "${var.dockerhub_password}"
    EOT
  }
}

resource "docker_image" "build_image" {
  name         = "my-docker-image"
  build {
    context    = "./"  
    dockerfile = "./Dockerfile"  
  }
}

resource "null_resource" "tag_image" {
  triggers = {
    docker_image_id = docker_image.build_image.image_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker tag ${docker_image.build_image.image_id} ${var.dockerhub_username}/${var.dockerhub_repository}:${local.image_tag}
    EOT
  }
}

resource "null_resource" "push_image" {
  triggers = {
    tag_image = null_resource.tag_image.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker push ${var.dockerhub_username}/${var.dockerhub_repository}:${local.image_tag}
    EOT
  }
}
