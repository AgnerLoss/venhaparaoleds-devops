provider "aws" {
  region = var.aws_region  # Usa a variável para definir a região
}

module "db" {
  source          = "./modules/db"
  db_username     = var.db_username
  db_password     = var.db_password
  db_name         = var.db_name
  security_group  = "sg-02473c56a241de8c5"
}

module "app" {
  source          = "./modules/app"
  db_host         = module.db.rds_endpoint  # Pega o endpoint gerado pelo módulo do banco
  db_username     = var.db_username
  db_password     = var.db_password
  db_name         = var.db_name
  db_port         = "5432"
  security_group  = "sg-02473c56a241de8c5"
  ghcr_token      = var.ghcr_token
}
