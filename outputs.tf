output "public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.app_server.public_ip
}