# Data source untuk mendapatkan AMI Amazon Linux 2 terbaru
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group untuk EC2
# WARNING: Untuk produksi, batasi cidr_blocks ke IP spesifik (contoh: ["YOUR_IP/32"])
# Konfigurasi saat ini membuka akses ke semua IP (0.0.0.0/0) untuk development
resource "aws_security_group" "web_server_sg" {
  name        = "restart-web-server-sg"
  description = "Security group untuk web server - mengizinkan HTTP dan SSH"

  # Ingress rule untuk HTTP (port 80)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # TODO: Batasi untuk produksi
  }

  # Ingress rule untuk SSH (port 22)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # TODO: Batasi untuk produksi
  }

  # Egress rule - mengizinkan semua traffic keluar
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "restart-web-server-sg"
  }
}

# Key Pair untuk akses SSH
resource "aws_key_pair" "deployer" {
  key_name   = "restart-devops-key"
  public_key = file("${path.module}/restart-devops.pub")
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  # Menggunakan security group yang sudah dibuat
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # User data untuk setup web server
  # IMPORTANT: user_data hanya berjalan saat instance pertama kali dibuat
  # Untuk apply perubahan user_data: terraform taint aws_instance.web_server && terraform apply
  user_data = <<-EOF
              #!/bin/bash
              # Update sistem
              yum update -y
              
              # Install Apache web server
              yum install -y httpd
              
              # Start dan enable Apache
              systemctl start httpd
              systemctl enable httpd
              
              # Deploy file HTML
              cat > /var/www/html/index.html <<'HTML'
              ${file("${path.module}/hello.html")}
              HTML
              
              # Set permissions
              chmod 644 /var/www/html/index.html
              
              # Restart Apache untuk memastikan perubahan diterapkan
              systemctl restart httpd
              EOF

  tags = {
    Name = "restart-web-server"
  }
}

# Output untuk menampilkan Public IP
output "instance_public_ip" {
  description = "Public IP address dari EC2 instance"
  value       = aws_instance.web_server.public_ip
}

# Output tambahan untuk informasi lengkap
output "instance_id" {
  description = "ID dari EC2 instance"
  value       = aws_instance.web_server.id
}

output "instance_public_dns" {
  description = "Public DNS dari EC2 instance"
  value       = aws_instance.web_server.public_dns
}

output "web_url" {
  description = "URL untuk mengakses web server"
  value       = "http://${aws_instance.web_server.public_ip}"
}
