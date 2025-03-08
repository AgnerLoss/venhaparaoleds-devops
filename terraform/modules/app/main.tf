resource "aws_instance" "app_server" {
  ami                    = "ami-094b981da55429bfc"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-02473c56a241de8c5"]
  associate_public_ip_address = true

  tags = {
    Name = "AppServerInstance"
  }

  user_data = <<-EOF
            #!/bin/bash
            set -e  # Faz o script parar em caso de erro

            echo "🔧 Atualizando pacotes..."
            sudo dnf update -y

            echo "🔧 Instalando Docker..."
            sudo dnf install -y docker

            echo "🔧 Iniciando serviços..."
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker ec2-user

            echo "🔧 Logando no GitHub Container Registry..."
            echo "${var.ghcr_token}" | sudo docker login ghcr.io -u USERNAME --password-stdin

            echo "🔧 Baixando e rodando o container Flask..."
            sudo docker pull ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
            sudo docker run -d -p 5000:5000 --name concurso-publico \
              -e DB_HOST="concurso-rds.c922aggume6k.us-west-1.rds.amazonaws.com" \
              -e DB_USER="${var.db_username}" \
              -e DB_PASS="${var.db_password}" \
              -e DB_NAME="${var.db_name}" \
              -e DB_PORT="5432" \
              ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest

            echo "✅ Configuração concluída com sucesso!"
EOF
}
