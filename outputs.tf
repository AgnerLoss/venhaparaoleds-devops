# 🔹 SAÍDA PARA VER O IP FIXO
output "elastic_ip" {
  description = "IP fixo da instância EC2"
  value       = aws_eip_association.elastic_ip_assoc.allocation_id
}