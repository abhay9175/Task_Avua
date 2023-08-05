terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

variable "dockerhub_username" {
  type = string
}

variable "dockerhub_password" {
  type = string
}

variable "aws_account" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "aws_profile" {
  type    = string
  default = "nishant"
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

resource "aws_ecr_repository" "my_python_app_repo" {
  name = "my-python-app-repo"
}

resource "null_resource" "docker_build" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command     = local.dkr_build_cmd
    interpreter = ["bash", "-c"]
  }
}

locals {
  ecr_repo         = "my-python-app-repo"
  image_tag        = "latest"
  dkr_img_src_path = "${path.module}/docker-src"
  dkr_img_src_sha256 = sha256(join("", [for f in fileset(local.dkr_img_src_path, "**") : filemd5(f.content)]))

  dkr_build_cmd = <<-EOT
    aws ecr get-login-password --region ${var.aws_region} --profile ${var.aws_profile} | docker login --username AWS --password-stdin ${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com
    docker build -t ${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.ecr_repo}:${local.image_tag} \
        -f ${local.dkr_img_src_path}/Dockerfile ${local.dkr_img_src_path}

    docker push ${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.ecr_repo}:${local.image_tag}
  EOT
}

