variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-west-1"  # Definindo a região como us-west-1
}

variable "ghcr_token" {
  description = "Token para login no GitHub Container Registry"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Usuário do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_port" {
  description = "Porta do banco de dados"
  type        = string
}

variable "db_host" {
  description = "Endpoint do banco de dados RDS"
  type        = string  
  default     = "concurso.c922aggume6k.us-west-1.rds.amazonaws.com"
}
