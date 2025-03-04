provider "aws" {
  region = var.aws_region  # Usa a variável para definir a região
}

resource "aws_instance" "app_server" {
  ami                    = "ami-094b981da55429bfc"  # AMI do Amazon Linux 2 (ou use um Ubuntu)
  instance_type          = "t2.micro"               # Tipo de instância Free Tier
  vpc_security_group_ids = ["sg-02473c56a241de8c5"]
  associate_public_ip_address = true  # Garante que a instância tenha IP público

  tags = {
    Name = "AppServerInstance"
  }

  # Script de inicialização para instalar Docker e configurar Nginx como proxy reverso
  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y docker nginx
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo systemctl start nginx
            sudo systemctl enable nginx
            sudo usermod -aG docker ec2-user

            # Configurar Nginx como proxy reverso para o Flask
            sudo bash -c 'cat > /etc/nginx/nginx.conf <<EOF2
            server {
                listen 80;
                server_name k8sloss.com.br www.k8sloss.com.br;

                location / {
                    proxy_pass http://127.0.0.1:5000;
                    proxy_set_header Host \$host;
                    proxy_set_header X-Real-IP \$remote_addr;
                    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                }
            }
            EOF2'

            # Reiniciar Nginx para aplicar a configuração
            sudo systemctl restart nginx

            # Login no GitHub Container Registry usando variável do Terraform
            echo "${var.ghcr_token}" | docker login ghcr.io -u USERNAME --password-stdin

            # Baixar e rodar o container
            docker pull ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
            docker run -d -p 5000:5000 --name concurso-publico \
              -e DB_HOST="concurso.c922aggume6k.us-west-1.rds.amazonaws.com" \
              -e DB_USER="admin2" \
              -e DB_PASS="SenhaSegura123!" \
              -e DB_NAME="concurso" \
              -e DB_PORT="5432" \
              ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
EOF
}

# 🔹 ASSOCIA O ELASTIC IP EXISTENTE À EC2
resource "aws_eip_association" "elastic_ip_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = "eipalloc-0402746a62babecd8"  # 🔹 Substitua pelo seu Allocation ID real
}

# 🔹 SAÍDA PARA VER O IP FIXO
output "elastic_ip" {
  description = "IP fixo da instância EC2"
  value       = aws_eip_association.elastic_ip_assoc.allocation_id
}
