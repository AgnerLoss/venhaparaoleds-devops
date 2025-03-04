from flask import Flask, jsonify, render_template, request
import psycopg2
import psycopg2.pool
import os

app = Flask(__name__)

# Configuração dinâmica do banco de dados PostgreSQL
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_PORT = os.getenv("DB_PORT", "5432")

# Garantir que o banco de dados existe antes de criar tabelas
def ensure_database_exists():
    """ Verifica se o banco existe, senão cria e adiciona tabelas. """
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            dbname="postgres",  # Conectar no banco padrão
            port=DB_PORT
        )
        conn.autocommit = True
        cur = conn.cursor()

        # Verifica se o banco "concurso" existe
        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s;", (DB_NAME,))
        exists = cur.fetchone()

        if not exists:
            cur.execute(f"CREATE DATABASE {DB_NAME};")
            app.logger.info(f"✅ Banco {DB_NAME} criado com sucesso!")
        
        cur.close()
        conn.close()
    except Exception as e:
        app.logger.error(f"❌ Erro ao verificar/criar banco de dados: {e}")

def create_tables():
    """ Cria as tabelas se elas não existirem. """
    conn = psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME,
        port=DB_PORT
    )
    conn.autocommit = True
    cur = conn.cursor()
    try:
        cur.execute("""
        CREATE TABLE IF NOT EXISTS concursos (
            id SERIAL PRIMARY KEY,
            orgao TEXT NOT NULL,
            edital TEXT NOT NULL,
            codigo TEXT NOT NULL,
            vagas TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS candidatos (
            id SERIAL PRIMARY KEY,
            nome TEXT NOT NULL,
            data_nascimento TEXT NOT NULL,
            cpf TEXT NOT NULL UNIQUE,
            profissoes TEXT NOT NULL
        );
        ""
        )
        app.logger.info("✅ Tabelas criadas/verificadas com sucesso.")
    except Exception as e:
        app.logger.error(f"❌ Erro ao criar tabelas: {e}")
    finally:
        cur.close()
        conn.close()

# Criar pool de conexões para evitar sobrecarga no banco
try:
    ensure_database_exists()
    create_tables()
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
