import pytest
from unittest.mock import patch, MagicMock
from src.app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

@pytest.fixture
def mock_db():
    with patch("src.app.get_db_connection") as mock_conn:
        mock_conn.return_value = MagicMock()
        mock_conn.return_value.cursor.return_value.fetchall.return_value = []
        yield mock_conn

def test_listar_concursos(client, mock_db):
    response = client.get("/concursos")
    assert response.status_code == 200
    assert response.json == []

def test_listar_candidatos(client, mock_db):
    response = client.get("/candidatos")
    assert response.status_code == 200
    assert response.json == []

def test_cadastrar_concurso(client, mock_db):
    response = client.post("/concursos", json={
        "orgao": "SEDU",
        "edital": "10/2024",
        "codigo": "12345",
        "vagas": ["professor"]
    })
    assert response.status_code == 201
    assert response.json == {"message": "Concurso cadastrado com sucesso!"}

def test_cadastrar_candidato(client, mock_db):
    response = client.post("/candidatos", json={
        "nome": "João Silva",
        "data_nascimento": "1990-01-01",
        "cpf": "12345678900",
        "profissoes": ["professor"]
    })
    assert response.status_code == 201
    assert response.json == {"message": "Candidato cadastrado com sucesso!"}

def test_buscar_concursos_por_cpf(client, mock_db):
    response = client.get("/buscar_concursos/12345678900")
    assert response.status_code in [200, 404]  # Pode ser que não encontre nada

def test_release_db_connection(mock_db):
    """Testa se a conexão é liberada corretamente."""
    conn = mock_db.return_value
    from src.app import release_db_connection
    
    release_db_connection(conn)

    if conn:  # Garante que conn existe antes de chamar putconn()
        conn.putconn.assert_called_once()


def test_create_tables(mock_db):
    """Testa se as tabelas são criadas corretamente no banco."""
    from src.app import create_tables
    create_tables()
    mock_db.return_value.cursor.return_value.execute.assert_called()

def test_listar_concursos(client, mock_db):
    """Testa se a API de concursos retorna a lista corretamente."""
    response = client.get("/concursos")
    assert response.status_code == 200
