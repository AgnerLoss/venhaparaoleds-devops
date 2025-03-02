provider "aws" {
  region = var.aws_region  # Usa a variável para definir a região
}

resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow HTTP and HTTPS traffic"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acesso público
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH (para acesso via terminal)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acesso de qualquer IP para EC2 Instance Connect
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-094b981da55429bfc"  # AMI do Amazon Linux 2 (Free Tier elegível)
  instance_type = "t2.micro"               # Tipo de instância Free Tier
  security_groups = [aws_security_group.web_sg.name]
  associate_public_ip_address = true  # Garante que a instância tenha IP público

  tags = {
    Name = "AppServerInstance"
  }

  # Script de inicialização (user data) para instalar Docker e rodar sua aplicação
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker pull ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
              docker run -d -p 80:80 ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
              EOF
}
