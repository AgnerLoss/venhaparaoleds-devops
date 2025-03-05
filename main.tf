provider "aws" {
  region = var.aws_region  # Usa a variável para definir a região
}

resource "aws_db_instance" "rds_postgres" {
  allocated_storage    = 20
  engine              = "postgres"
  engine_version      = "17.4"
  instance_class      = "db.t3.micro"
  identifier          = "concurso-rds"
  username           = var.db_username
  password           = var.db_password
  db_name            = var.db_name
  publicly_accessible = true
  skip_final_snapshot = true
  vpc_security_group_ids = ["sg-02473c56a241de8c5"]
}

resource "aws_instance" "app_server" {
  ami                    = "ami-094b981da55429bfc"  # AMI do Amazon Linux 2 (ou use um Ubuntu)
  instance_type          = "t2.micro"               # Tipo de instância Free Tier
  vpc_security_group_ids = ["sg-02473c56a241de8c5"]
  associate_public_ip_address = true  # Garante que a instância tenha IP público

  tags = {
    Name = "AppServerInstance"
  }

  # Script de inicialização para instalar Docker e configurar Nginx
  user_data = <<-EOF
            #!/bin/bash
            set -e  # Faz o script parar em caso de erro

            echo "🔧 Atualizando pacotes..."
            sudo dnf update -y

            echo "🔧 Instalando Docker e Nginx..."
            sudo dnf install -y docker nginx postgresql15

            echo "🔧 Iniciando serviços..."
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo systemctl start nginx
            sudo systemctl enable nginx
            sudo usermod -aG docker ec2-user

            echo "🔧 Configurando Nginx como proxy reverso..."
            sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF2
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
            EOF2

            echo "🔧 Reiniciando Nginx..."
            sudo systemctl restart nginx

            echo "🔧 Logando no GitHub Container Registry..."
            echo "${var.ghcr_token}" | sudo docker login ghcr.io -u USERNAME --password-stdin

            echo "🔧 Baixando e rodando o container Flask..."
            sudo docker pull ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
            sudo docker run -d -p 5000:5000 --name concurso-publico \
              -e DB_HOST="${aws_db_instance.rds_postgres.endpoint}" \
              -e DB_USER="${var.db_username}" \
              -e DB_PASS="${var.db_password}" \
              -e DB_NAME="${var.db_name}" \
              -e DB_PORT="${var.db_port}" \
              ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest

            echo "✅ Configuração concluída com sucesso!"
EOF
}

# 🔹 ASSOCIA O ELASTIC IP EXISTENTE À EC2
resource "aws_eip_association" "elastic_ip_assoc" {
  instance_id   = aws_instance.app_server.id
  allocation_id = "eipalloc-0402746a62babecd8"  # 🔹 Substitua pelo seu Allocation ID real
}

# 🔹 EXECUTA O SCRIPT SQL PARA CRIAR TABELAS APÓS O BANCO ESTAR PRONTO
resource "null_resource" "init_db" {
  depends_on = [aws_db_instance.rds_postgres]

  provisioner "local-exec" {
    command = <<EOT
      echo "⏳ Aguardando o banco de dados estar pronto..."
      
      # Loop para verificar se o RDS já está acessível
      for i in $(seq 1 20); do
        PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.rds_postgres.endpoint}" -U "${var.db_username}" -d "${var.db_name}" -c "SELECT 1;" && break
        echo "🔄 Banco ainda não disponível... aguardando 15 segundos"
        sleep 15
      done
      
      echo "🚀 Criando tabelas no banco..."
      PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.rds_postgres.endpoint}" -U "${var.db_username}" -d "${var.db_name}" -f init.sql || (echo "❌ ERRO: Falha ao criar as tabelas" && exit 1)
      echo "✅ Tabelas criadas com sucesso!"
    EOT
  }
}

# 🔹 SAÍDA PARA VER O ENDPOINT DO RDS
output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = aws_db_instance.rds_postgres.endpoint
}
