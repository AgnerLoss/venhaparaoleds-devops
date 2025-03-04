provider "aws" {
  region = var.aws_region  # Usa a variável para definir a região
}

resource "aws_instance" "app_server" {
  ami                    = "ami-094b981da55429bfc"  # AMI do Amazon Linux 2 (ou use um Ubuntu)
  instance_type          = "t2.micro"               # Tipo de instância Free Tier
  security_groups        = ["sg-02473c56a241de8c5"]
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

