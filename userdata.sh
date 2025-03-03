#!/bin/bash
# Atualizar pacotes e instalar Docker
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Login no GitHub Container Registry
echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin

# Baixar e rodar o container da aplicação
docker pull ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
docker run -d -p 5000:5000 --name concurso-publico \
  -e DB_HOST="<IP_DO_BANCO>" \
  -e DB_USER="admin2" \
  -e DB_PASS="SenhaSegura123!" \
  -e DB_NAME="concurso" \
  -e DB_PORT="5432" \
  ghcr.io/agnerloss/venhaparaoleds-devops/concurso-publico:latest
