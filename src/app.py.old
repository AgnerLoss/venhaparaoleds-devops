from flask import Flask, jsonify, render_template, request
import psycopg2
import psycopg2.pool
import os

app = Flask(__name__)

# Configuração do banco de dados PostgreSQL
DB_HOST = os.getenv("DB_HOST", "db")
DB_USER = os.getenv("DB_USER", "admin2")
DB_PASS = os.getenv("DB_PASS", "SenhaSegura123!")
DB_NAME = os.getenv("DB_NAME", "concurso")
DB_PORT = os.getenv("DB_PORT", "5432")

# Criar pool de conexões para evitar sobrecarga no banco
db_pool = psycopg2.pool.SimpleConnectionPool(1, 10, host=DB_HOST, user=DB_USER, password=DB_PASS, dbname=DB_NAME, port=DB_PORT)

def get_db_connection():
    try:
        return db_pool.getconn()
    except Exception as e:
        app.logger.error(f"Erro ao conectar ao banco: {e}")
        return None

def release_db_connection(conn):
    if conn:
        db_pool.putconn(conn)

@app.route('/')
def index():
    return render_template('index.html')  # Página principal de busca

@app.route('/cadastro')
def cadastro():
    return render_template('cadastro.html')  # Página de cadastro

@app.route('/concursos', methods=['GET', 'POST'])
def listar_concursos():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500
    
    if request.method == 'POST':
        data = request.get_json()
        cur = conn.cursor()
        cur.execute("INSERT INTO concursos (orgao, edital, codigo, vagas) VALUES (%s, %s, %s, %s) RETURNING id;", 
                    (data['orgao'], data['edital'], data['codigo'], ', '.join(data['vagas'])))
        conn.commit()
        cur.close()
        release_db_connection(conn)
        return jsonify({"message": "Concurso cadastrado com sucesso!"}), 201
    
    cur = conn.cursor()
    cur.execute("SELECT * FROM concursos;")
    concursos = cur.fetchall()
    cur.close()
    release_db_connection(conn)
    
    return jsonify([{"id": c[0], "orgao": c[1], "edital": c[2], "codigo": c[3], "vagas": c[4]} for c in concursos])

@app.route('/candidatos', methods=['GET', 'POST'])
def listar_candidatos():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500
    
    if request.method == 'POST':
        data = request.get_json()
        cur = conn.cursor()
        cur.execute("INSERT INTO candidatos (nome, data_nascimento, cpf, profissoes) VALUES (%s, %s, %s, %s) RETURNING id;", 
                    (data['nome'], data['data_nascimento'], data['cpf'], ', '.join(data['profissoes'])))
        conn.commit()
        cur.close()
        release_db_connection(conn)
        return jsonify({"message": "Candidato cadastrado com sucesso!"}), 201
    
    cur = conn.cursor()
    cur.execute("SELECT * FROM candidatos;")
    candidatos = cur.fetchall()
    cur.close()
    release_db_connection(conn)
    
    return jsonify([{"id": c[0], "nome": c[1], "data_nascimento": c[2], "cpf": c[3], "profissoes": c[4]} for c in candidatos])

@app.route('/buscar_concursos/<cpf>', methods=['GET'])
def buscar_concursos_por_cpf(cpf):
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500
    
    cur = conn.cursor()
    cur.execute("""
        SELECT c.orgao, c.codigo, c.edital
        FROM concursos c
        JOIN candidatos cand ON string_to_array(c.vagas, ', ') && string_to_array(cand.profissoes, ', ')
        WHERE cand.cpf = %s;
    """, (cpf,))
    concursos = cur.fetchall()
    cur.close()
    release_db_connection(conn)
    
    if not concursos:
        return jsonify({"message": "Nenhum concurso encontrado para este CPF."}), 404
    
    return jsonify([{"orgao": c[0], "codigo": c[1], "edital": c[2]} for c in concursos])

@app.route('/buscar_candidatos/<codigo>', methods=['GET'])
def buscar_candidatos_por_codigo(codigo):
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Não foi possível conectar ao banco"}), 500
    
    cur = conn.cursor()
    cur.execute("""
        SELECT cand.nome, cand.data_nascimento, cand.cpf
        FROM candidatos cand
        JOIN concursos c ON string_to_array(c.vagas, ', ') && string_to_array(cand.profissoes, ', ')
        WHERE c.codigo = %s;
    """, (codigo,))
    candidatos = cur.fetchall()
    cur.close()
    release_db_connection(conn)
    
    if not candidatos:
        return jsonify({"message": "Nenhum candidato encontrado para este concurso."}), 404
    
    return jsonify([{"nome": c[0], "data_nascimento": c[1], "cpf": c[2]} for c in candidatos])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
