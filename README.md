# 📌 Projeto: API de Gerenciamento de Concursos Públicos

## 📖 Sobre o Projeto
Este projeto é uma API REST desenvolvida em **Flask**, que permite gerenciar concursos públicos e candidatos. A aplicação utiliza um banco de dados **PostgreSQL** hospedado na **AWS RDS**, é containerizada via **Docker** e gerenciada através de **Terraform** para infraestrutura como código.

## 🏗 Arquitetura e Tecnologias Utilizadas
### **Tecnologias**
- **Linguagem:** Python 3.12 + Flask
- **Banco de Dados:** PostgreSQL (AWS RDS)
- **Infraestrutura:** AWS (EC2 + RDS) gerenciado com Terraform
- **Containerização:** Docker
- **CI/CD:** GitHub Actions + SonarQube + Trivy
- **Testes:** pytest + unittest

### **Fluxo da Aplicação**
1. O usuário realiza requisições HTTP para a API.
2. A API consulta ou armazena dados no banco PostgreSQL.
3. O banco de dados retorna os resultados para a API.
4. A API responde ao usuário com os dados formatados em JSON.

## 🚀 Como Configurar e Rodar a Aplicação
### **1️⃣ Pré-requisitos**
Antes de começar, garanta que você tenha instalado:
- **Docker e Docker Compose**
- **Terraform**
- **AWS CLI configurado**

### **2️⃣ Configurar a Infraestrutura na AWS**
```bash
cd terraform/
terraform init
terraform apply -auto-approve
```
Isso criará a infraestrutura necessária, incluindo a instância EC2 e o banco de dados RDS.

### **3️⃣ Rodar a Aplicação Localmente**
Se quiser rodar a API localmente, primeiro configure suas variáveis de ambiente:
```bash
export DB_HOST="seu-rds-endpoint"
export DB_USER="seu-usuario"
export DB_PASS="sua-senha"
export DB_NAME="concurso"
export DB_PORT="5432"
```
Agora inicie a API:
```bash
python src/app.py
```
A API estará disponível em **http://127.0.0.1:5000**.

### **4️⃣ Rodar a Aplicação com Docker**
Se preferir usar Docker:
```bash
docker build -t concurso-publico .
docker run -d -p 5000:5000 --name concurso-publico \
    -e DB_HOST="$DB_HOST" \
    -e DB_USER="$DB_USER" \
    -e DB_PASS="$DB_PASS" \
    -e DB_NAME="$DB_NAME" \
    -e DB_PORT="$DB_PORT" \
    concurso-publico
```
Acesse **http://localhost:5000** para interagir com a API.

## 🛠 Endpoints da API
### **📌 Concursos**
- `GET /concursos` → Lista todos os concursos.
- `POST /concursos` → Cadastra um novo concurso.
- `GET /buscar_concursos/<cpf>` → Retorna concursos compatíveis com um CPF.

### **📌 Candidatos**
- `GET /candidatos` → Lista todos os candidatos.
- `POST /candidatos` → Cadastra um novo candidato.
- `GET /buscar_candidatos/<codigo>` → Retorna candidatos compatíveis com um concurso.

## ✅ Como Rodar os Testes
A aplicação possui testes unitários e de integração utilizando **pytest**.
```bash
pytest --cov=src --cov-report=term-missing
```
Isso irá rodar os testes e exibir a cobertura de código.

## 🔄 CI/CD e Deploy
O projeto conta com um **pipeline automatizado** via GitHub Actions:
1. **Testes e Análise de Código:**
   - Linting e testes unitários com cobertura.
   - SonarQube para análise de qualidade do código.
   - Trivy para escanear vulnerabilidades em imagens Docker.
2. **Build e Deploy:**
   - Construção da imagem Docker.
   - Publicação no **GitHub Container Registry (GHCR)**.
   - Provisionamento automático da infraestrutura na AWS via Terraform.

## 📌 Melhorias Futuras
- Adicionar autenticação JWT na API.
- Implementar cache Redis para otimizar buscas.
- Criar interface web para gerenciamento dos concursos.

## 🏆 Conclusão
Esse projeto foi estruturado para ser escalável e modular, seguindo **boas práticas de Clean Code, infraestrutura como código e CI/CD**. 🚀

---
📩 **Contato:** Caso tenha dúvidas ou sugestões, me avise! 😃

