provider "aws" {
  region = var.aws_region  # Usa a variável para definir a região
}

resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow HTTP, HTTPS, and Flask"

  ingress {
    description = "Allow Flask (porta 5000)"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acesso público
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
  ami                    = "ami-094b981da55429bfc"  # AMI do Amazon Linux 2 (ou use um Ubuntu)
  instance_type          = "t2.micro"               # Tipo de instância Free Tier
  security_groups        = [aws_security_group.web_sg.name]
  associate_public_ip_address = true  # Garante que a instância tenha IP público

  tags = {
    Name = "AppServerInstance"
  }

  # Script de inicialização para instalar Docker e rodar sua aplicação
  user_data = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y docker
            systemctl start docker
            systemctl enable docker
            usermod -aG docker ec2-user

            # Login no GitHub Container Registry usando variável do Terraform
            echo "${var.ghcr_token}" | docker login ghcr.io -u USERNAME --password-stdin

            # Baixar e rodar o container
            docker pull ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
            docker run -d -p 5000:5000 --name concurso-publico \
              -e DB_HOST="db" \
              -e DB_USER="admin2" \
              -e DB_PASS="SenhaSegura123!" \
              -e DB_NAME="concurso" \
              -e DB_PORT="5432" \
              ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
            EOF

}

