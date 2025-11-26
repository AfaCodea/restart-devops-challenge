data "aws_ami" "amazon-linux" {
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
  ami                       = data.aws_ami.amazon-linux.id
  instance_type             = "t3.micro"
  vpc_security_group_ids    = [aws_security_group.challenge_sg.id]
  user_data_replace_on_change = true

  tags = {
    Name = "AWSrestart"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Create index.html directly
              cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html>

<head>
    <title>Hello World!</title>
</head>

<body>
    <h1>Halo Agil Prasunza!</h1>
    <p>Deploy ke 2 berhasil menggunakan user_data.</p>
</body>

</html>
Test deployment 3
HTML
              EOF
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.challenge.public_ip
}