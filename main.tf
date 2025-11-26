provider "aws" {
  region  = "ap-southeast-3"
  profile = "restart"
}

# Amazon Linux 2023 kernel-6.1 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-0559665adb3f0e333"]
  }
}

resource "aws_security_group" "challenge_sg" {
  name        = "challenge_sg"
  description = "Security group for the challenge instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "challenge" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.challenge_sg.id]

  tags = {
    Name = "AWSrestart"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    html_content = file("${path.module}/hello.html")
  })

  user_data_replace_on_change = true
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.challenge.public_ip
}