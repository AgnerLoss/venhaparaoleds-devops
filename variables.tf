variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-west-1"  # Definindo a região como us-west-1
}

variable "ghcr_token" {
  description = "Token para login no GitHub Container Registry"
  type        = string
}