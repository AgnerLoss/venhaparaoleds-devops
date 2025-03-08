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

output "rds_endpoint" {
  value = aws_db_instance.rds_postgres.endpoint
}

resource "null_resource" "init_db" {
  depends_on = [aws_db_instance.rds_postgres]

  provisioner "local-exec" {
    command = <<EOT
      echo "⏳ Aguardando o banco de dados estar pronto..."
      
      # Loop para verificar se o RDS já está acessível
      for i in $(seq 1 20); do
        PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.rds_postgres.address}" -U "${var.db_username}" -d "${var.db_name}" -c "SELECT 1;" && break
        echo "🔄 Banco ainda não disponível... aguardando 15 segundos"
        sleep 15
      done

      echo "🚀 Criando tabelas no banco..."
      PGPASSWORD="${var.db_password}" psql -h "${aws_db_instance.rds_postgres.address}" -U "${var.db_username}" -d "${var.db_name}" <<EOSQL
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
    EOT
  }
}

