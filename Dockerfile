# Usando a imagem oficial do Python
FROM python:3.12-slim
WORKDIR /app

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Copiar o arquivo de dependências
COPY requirements.txt .

# Criar um ambiente virtual e instalar as dependências corretamente
RUN python3 -m venv /app/venv && \
    /app/venv/bin/python -m pip install --no-cache-dir --upgrade pip && \
    /app/venv/bin/python -m pip install --no-cache-dir -r requirements.txt && \
    echo "Listando /app após criação do venv:" && ls -l /app && \
    echo "Listando /app/venv/bin para verificar o Python:" && ls -l /app/venv/bin/

# Copiar o código-fonte
COPY src/ ./src/

# Configurar o PATH para usar o ambiente virtual
ENV PATH="/app/venv/bin:$PATH"

# Configurar o ambiente Flask corretamente
ENV FLASK_APP=/app/src/app.py
ENV FLASK_ENV=production

# Expor a porta do Flask
EXPOSE 5000

# Definir o comando padrão para rodar o Flask
ENTRYPOINT ["/bin/sh", "-c", ". /app/venv/bin/activate && python /app/src/app.py"]
