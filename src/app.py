from flask import Flask, jsonify, render_template, request
import psycopg2
import psycopg2.pool
import os
import time

app = Flask(__name__)

# Configuração dinâmica do banco de dados PostgreSQL
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_PORT = os.getenv("DB_PORT", "5432")

# Função para aguardar o banco de dados ficar disponível
def wait_for_db():
    """ Aguarda o banco de dados estar pronto antes de conectar """
    max_retries = 10
    retries = 0

    while retries < max_retries:
        try:
            conn = psycopg2.connect(
                host=DB_HOST,
                user=DB_USER,
                password=DB_PASS,
                dbname=DB_NAME,
                port=DB_PORT
            )
            conn.close()
            app.logger.info("✅ Banco de dados disponível!")
            return
        except Exception as e:
            app.logger.warning(f"⏳ Banco de dados ainda não disponível, tentando novamente... ({retries+1}/{max_retries})")
            time.sleep(5)
            retries += 1

    app.logger.error("❌ Banco de dados não ficou disponível dentro do tempo limite.")
    exit(1)  # Sai com erro se o banco nunca estiver disponível

# Aguarda o banco antes de prosseguir
wait_for_db()

# Criar pool de conexões para evitar sobrecarga no banco
try:
    db_pool = psycopg2.pool.SimpleConnectionPool(
        1, 10,
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME,
        port=DB_PORT
    )
    app.logger.info("✅ Conexão com o banco estabelecida com sucesso!")
except Exception as e:
    app.logger.error(f"❌ Erro ao conectar ao banco: {e}")
    db_pool = None

def get_db_connection():
    """ Obtém uma conexão do pool """
    try:
        return db_pool.getconn()
    except Exception as e:
        app.logger.error(f"Erro ao conectar ao banco: {e}")
        return None

def release_db_connection(conn):
    """ Libera uma conexão de volta para o pool """
    if conn:
        db_pool.putconn(conn)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
