---

# Projeto: Sistema de Gerenciamento de Concurso Público

---

Este projeto foi desenvolvido com o auxílio de ferramentas de Inteligência Artificial (IA) para aprimorar a qualidade do código, documentação e boas práticas. 

- **[DeepSeek](https://www.deepseek.com/)**: Para insights e otimizações no desenvolvimento.
- **[ChatGPT](https://openai.com/chatgpt)**: Para revisão de código, sugestões e documentação.
- **[Grok](https://grok.ai/)**: Para análises e recomendações técnicas.

---

# 📋 Concurso Público API 🚀

## **Descrição do Projeto**
Este projeto é uma API REST desenvolvida em **Flask** para gerenciar concursos públicos e candidatos.  
A aplicação está implantada na **AWS** usando:
- **EC2** para rodar o backend com **Docker**
- **RDS PostgreSQL** para armazenar os dados
- **Terraform** para provisionar a infraestrutura
- **Nginx** como proxy reverso para direcionar requisições ao Flask

---

## **📋 Tecnologias Utilizadas**
- 🦄 **Python 3.12** + **Flask**
- 💢 **Docker**
- ☁️ **AWS EC2 + RDS PostgreSQL**
- 🌿 **Terraform**
- 🌍 **Nginx (Proxy Reverso)**
- 🔍 **PostgreSQL**
- 🛠️ **GitHub Actions (CI/CD)**

---

## **📁 Como Rodar o Projeto**
### **1️⃣ Clonar o repositório**
```sh
git clone https://github.com/SEU-USUARIO/SEU-REPO.git
cd SEU-REPO
```

### **2️⃣ Subir a Infraestrutura na AWS com Terraform**
Certifique-se de configurar suas **chaves da AWS** antes de rodar:
```sh
export AWS_ACCESS_KEY_ID="SEU_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="SEU_SECRET_KEY"
terraform init
terraform apply -auto-approve
```
Isso criará:
✅ Uma instância **EC2** com **Docker e Nginx**  
✅ Um banco de dados **RDS PostgreSQL**  
✅ Um **Elastic IP fixo** para a EC2  

### **3️⃣ Testar a API**
Pegue o **IP da EC2** e acesse:
```sh
curl -X GET "http://SEU_IP_FIXO/buscar_candidatos/61828450843"
```
Se o Nginx estiver configurado corretamente, a API estará acessível em:
```
http://k8sloss.com.br
```

---

## **🔍 Endpoints da API**
### **📍 Listar Concursos por CPF**
- **Método:** `GET`
- **Endpoint:** `/buscar_concursos/<cpf>`
- **Exemplo:**
```sh
curl -X GET "http://SEU_IP_FIXO/buscar_concursos/18284508434"
```

### **📍 Listar Candidatos por Código do Concurso**
- **Método:** `GET`
- **Endpoint:** `/buscar_candidatos/<codigo>`
- **Exemplo:**
```sh
curl -X GET "http://SEU_IP_FIXO/buscar_candidatos/61828450843"
```

---

## **🌐 Configuração do Proxy Reverso com Nginx**

### **Arquivo de configuração do Nginx (`/etc/nginx/nginx.conf`)**
```nginx
server {
    listen 80;
    server_name k8sloss.com.br www.k8sloss.com.br;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### **Reiniciar o Nginx para aplicar mudanças**
```sh
sudo systemctl restart nginx
```

---

## **🏢 Infraestrutura AWS com Terraform**

### **📍 Recursos Criados**
✅ **EC2** (Instância com Docker e Nginx)  
✅ **RDS PostgreSQL** (Banco gerenciado)  
✅ **Security Groups** (Permissões para tráfego HTTP e PostgreSQL)  
✅ **Elastic IP** (IP fixo para a EC2)

---

## **🚀 Como Fazer Deploy Automático (CI/CD)**

O projeto pode ser configurado com **GitHub Actions** para deploy contínuo.

### **Exemplo de workflow (`.github/workflows/deploy.yml`)**
```yaml
name: Deploy Infra to AWS

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: "1.5.0"

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

Agora, **sempre que fizer um push para `main`**, o Terraform será executado automaticamente! 🚀🔥

---

