provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_security_group" "go_app_sg" {
  name_prefix = "go-app-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "go_app_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with your desired AMI ID
  instance_type = "t2.micro"             # Replace with your desired instance type
  key_name      = "your-keypair-name"    # Replace with your key pair name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.go_app_sg.id]

  provisioner "local-exec" {
    command = <<-EOT
      scp -i ${var.private_key_path} -o "StrictHostKeyChecking=no" app.go ec2-user@${self.public_ip}:/home/ec2-user/app.go
      ssh -i ${var.private_key_path} -o "StrictHostKeyChecking=no" ec2-user@${self.public_ip} "nohup go run /home/ec2-user/app.go > /dev/null 2>&1 &"
    EOT
  }
}

output "go_app_url" {
  value = "http://${aws_instance.go_app_instance.public_ip}:8080"
}

