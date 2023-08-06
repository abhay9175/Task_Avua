provider "aws" {
  region = "ap-northeast-1"  
}

resource "aws_eks_cluster" "main" {
  name     = "hello-go-app-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "hello-go-app-node-group"
  instance_type   = "t2.micro"
  desired_size    = 1
  min_size        = 1
  max_size        = 2
}

output "kubeconfig" {
  value = aws_eks_cluster.main.kubeconfig_filename
}

