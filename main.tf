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

  ingress {
    from_port   = 3000
    to_port     = 3000
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

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install git
              yum install -y git
              
              # Install Node.js 20.x (LTS)
              curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
              yum install -y nodejs
              
              # Install PM2 globally
              npm install -g pm2
              
              # Clone repository
              cd /home/ec2-user
              git clone https://github.com/AfaCodea/restart-devops-challenge.git
              cd restart-devops-challenge/webshoesstore
              
              # Install dependencies and build
              npm install
              npm run build
              
              # Start Next.js with PM2
              pm2 start npm --name "webshoesstore" -- start
              pm2 startup systemd -u ec2-user --hp /home/ec2-user
              pm2 save
              
              # Setup nginx as reverse proxy
              yum install -y nginx
              cat > /etc/nginx/conf.d/nextjs.conf <<'NGINX'
              server {
                  listen 80;
                  server_name _;
                  
                  location / {
                      proxy_pass http://localhost:3000;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade \$http_upgrade;
                      proxy_set_header Connection 'upgrade';
                      proxy_set_header Host \$host;
                      proxy_cache_bypass \$http_upgrade;
                  }
              }
              NGINX
              
              # Start nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  user_data_replace_on_change = true
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.challenge.public_ip
}