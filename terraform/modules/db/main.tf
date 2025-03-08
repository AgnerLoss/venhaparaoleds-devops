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
