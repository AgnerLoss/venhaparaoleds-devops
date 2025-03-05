from flask import Flask, jsonify, render_template, request
import psycopg2
import psycopg2.pool
import os

app = Flask(__name__)

# Configuração do banco de dados PostgreSQL no RDS
DB_HOST = os.getenv("DB_HOST", "concurso-rds.c922aggume6k.us-west-1.rds.amazonaws.com")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")
DB_PORT = os.getenv("DB_PORT", "5432")

# Criar pool de conexões para evitar sobrecarga no banco
try:
    db_pool = psycopg2.pool.SimpleConnectionPool(1, 10,
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

def create_tables():
    """ Cria as tabelas no banco de dados se não existirem """
    conn = get_db_connection()
    if not conn:
        app.logger.error("❌ Não foi possível conectar ao banco para criar tabelas.")
        return

    try:
        cur = conn.cursor()
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
        """)
        conn.commit()
        cur.close()
        app.logger.info("✅ Tabelas criadas/verificadas com sucesso.")
    except Exception as e:
        app.logger.error(f"❌ Erro ao criar tabelas: {e}")
    finally:
        release_db_connection(conn)

# Criar tabelas ao iniciar a aplicação
with app.app_context():
    create_tables()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/cadastro')
def cadastro():
    return render_template('cadastro.html')

@app.route('/concursos', methods=['GET', 'POST'])
def listar_concursos():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500
    
    try:
        cur = conn.cursor()
        if request.method == 'POST':
            data = request.get_json()
            cur.execute("INSERT INTO concursos (orgao, edital, codigo, vagas) VALUES (%s, %s, %s, %s) RETURNING id;",
                        (data['orgao'], data['edital'], data['codigo'], ', '.join(data['vagas'])))
            conn.commit()
            cur.close()
            return jsonify({"message": "Concurso cadastrado com sucesso!"}), 201

        cur.execute("SELECT * FROM concursos;")
        concursos = cur.fetchall()
        cur.close()
        return jsonify([{"id": c[0], "orgao": c[1], "edital": c[2], "codigo": c[3], "vagas": c[4]} for c in concursos])
    
    except Exception as e:
        return jsonify({"error": f"Erro ao acessar o banco: {e}"}), 500
    finally:
        release_db_connection(conn)

@app.route('/candidatos', methods=['GET', 'POST'])
def listar_candidatos():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500
    
    try:
        cur = conn.cursor()
        if request.method == 'POST':
            data = request.get_json()
            cur.execute("INSERT INTO candidatos (nome, data_nascimento, cpf, profissoes) VALUES (%s, %s, %s, %s) RETURNING id;",
                        (data['nome'], data['data_nascimento'], data['cpf'], ', '.join(data['profissoes'])))
            conn.commit()
            cur.close()
            return jsonify({"message": "Candidato cadastrado com sucesso!"}), 201

        cur.execute("SELECT * FROM candidatos;")
        candidatos = cur.fetchall()
        cur.close()
        return jsonify([{"id": c[0], "nome": c[1], "data_nascimento": c[2], "cpf": c[3], "profissoes": c[4]} for c in candidatos])

    except Exception as e:
        return jsonify({"error": f"Erro ao acessar o banco: {e}"}), 500
    finally:
        release_db_connection(conn)

@app.route('/buscar_concursos/<cpf>', methods=['GET'])
def buscar_concursos_por_cpf(cpf):
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500

    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT c.orgao, c.codigo, c.edital
            FROM concursos c
            JOIN candidatos cand ON string_to_array(c.vagas, ', ') && string_to_array(cand.profissoes, ', ')
            WHERE cand.cpf = %s;
        """, (cpf,))
        concursos = cur.fetchall()
        cur.close()

        if not concursos:
            return jsonify({"message": "Nenhum concurso encontrado para este CPF."}), 404

        return jsonify([{"orgao": c[0], "codigo": c[1], "edital": c[2]} for c in concursos])
    
    except Exception as e:
        return jsonify({"error": f"Erro ao buscar concursos: {e}"}), 500
    finally:
        release_db_connection(conn)

@app.route('/buscar_candidatos/<codigo>', methods=['GET'])
def buscar_candidatos_por_codigo(codigo):
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500

    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT cand.nome, cand.data_nascimento, cand.cpf
            FROM candidatos cand
            JOIN concursos c ON c.codigo = %s
            WHERE EXISTS (
                SELECT 1
                FROM unnest(string_to_array(c.vagas, ', ')) AS vaga
                JOIN unnest(string_to_array(cand.profissoes, ', ')) AS profissao 
                ON vaga = profissao
            )
        """, (codigo,))
        candidatos = cur.fetchall()
        cur.close()

        if not candidatos:
            return jsonify({"message": "Nenhum candidato encontrado para este concurso."}), 404

        return jsonify([{"nome": c[0], "data_nascimento": c[1], "cpf": c[2]} for c in candidatos])

    except Exception as e:
        return jsonify({"error": f"Erro ao buscar candidatos: {e}"}), 500
    finally:
        release_db_connection(conn)




if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
