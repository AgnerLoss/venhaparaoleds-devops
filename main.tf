provider "aws" {
  region = var.aws_region  # Usa a variável para definir a região
}

resource "aws_instance" "app_server" {
  ami           = "ami-07d2649d67dbe8900"  # AMI do Ubuntu 24.04 LTS na us-west-1 (Free Tier elegível)
  instance_type = "t2.micro"               # Tipo de instância Free Tier

  tags = {
    Name = "AppServerInstance"
  }

  # Script de inicialização (user data) para instalar Docker e rodar sua aplicação
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              docker run -d -p 80:80 ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
              EOF
}

