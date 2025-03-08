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

            echo "🔧 Instalando Docker e PostgreSQL Client..."
            sudo dnf install -y docker postgresql

            echo "🔧 Iniciando serviços..."
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker ec2-user

            echo "⏳ Aguardando o banco de dados ficar pronto..."
            for i in $(seq 1 20); do
              PGPASSWORD="${var.db_password}" psql -h "${var.db_host}" -U "${var.db_username}" -d "${var.db_name}" -c "SELECT 1;" && break
              echo "🔄 Banco ainda não disponível... aguardando 15 segundos"
              sleep 15
            done

            echo "🚀 Criando tabelas no banco..."
            PGPASSWORD="${var.db_password}" psql -h "${var.db_host}" -U "${var.db_username}" -d "${var.db_name}" <<EOSQL
            CREATE TABLE IF NOT EXISTS concursos (
                id SERIAL PRIMARY KEY,
                orgao TEXT NOT NULL,
                edital TEXT NOT NULL,
                codigo TEXT NOT NULL,
                vagas TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS candidatos (
                id SERIAL PRIMARY KEY,
                nome TEXT NOT NULL,
                data_nascimento TEXT NOT NULL,
                cpf TEXT NOT NULL UNIQUE,
                profissoes TEXT NOT NULL
            );
            EOSQL

            echo "✅ Tabelas criadas com sucesso!"

            echo "🔧 Logando no GitHub Container Registry..."
            echo "${var.ghcr_token}" | sudo docker login ghcr.io -u USERNAME --password-stdin

            echo "🔧 Baixando e rodando o container Flask..."
            sudo docker pull ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
            sudo docker run -d -p 5000:5000 --name concurso-publico \
              -e DB_HOST="${var.db_host}" \
              -e DB_USER="${var.db_username}" \
              -e DB_PASS="${var.db_password}" \
              -e DB_NAME="${var.db_name}" \
              -e DB_PORT="${var.db_port}" \
              ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest

            echo "✅ Configuração concluída com sucesso!"
EOF
}


