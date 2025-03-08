import pytest
from unittest.mock import patch, MagicMock
from src.candidato import Candidato
from src.app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


@pytest.fixture
def mock_db():
    """Mock do banco de dados para evitar conexões reais."""
    with patch("src.app.get_db_connection") as mock_conn:
        mock_conn.return_value = MagicMock()
        mock_cursor = mock_conn.return_value.cursor.return_value
        mock_cursor.fetchall.return_value = [("João Silva", "1990-01-01", "12345678900", "professor")]
        mock_cursor.fetchone.return_value = None  # Evita erro de conexão
        yield mock_conn



def test_candidato_corresponde_ao_concurso():
    candidato = Candidato("Lindsey Craft", "1976-05-19", "18284508434", ["carpinteiro"])
    assert candidato.corresponde_ao_concurso(["carpinteiro", "marceneiro"]) is True
    assert candidato.corresponde_ao_concurso(["professor"]) is False


def test_candidato_de_linha():
    """Testa a conversão de uma linha de texto para um objeto Candidato."""
    linha = "Lindsey Craft\t19/05/1976\t18284508434\t['carpinteiro']"
    candidato = Candidato.de_linha(linha)
    assert candidato.nome == "Lindsey Craft"
    assert candidato.data_nascimento == "1976-05-19"  # Verifica formatação correta
    assert candidato.cpf == "18284508434"
    assert candidato.profissoes == ["carpinteiro"]


def test_candidato_api(client, mock_db):
    """Testa se a API de candidatos retorna código HTTP 200."""
    response = client.get("/candidatos")
    assert response.status_code == 200


def test_buscar_concursos_por_cpf(client, mock_db):
    """Testa se a busca por concursos retorna corretamente."""
    response = client.get("/buscar_concursos/18284508434")
    assert response.status_code == 200
    assert response.json == [{"orgao": "SEDU", "codigo": "61828450843", "edital": "9/2016"}]


def test_candidato_cpf_invalido():
    """Testa se a validação de CPF inválido está funcionando."""
    with pytest.raises(ValueError):
        Candidato("Nome Teste", "2000-01-01", "123", ["professor"])


def test_candidato_repr():
    """Testa a representação textual do objeto Candidato."""
    candidato = Candidato("João", "1990-01-01", "12345678900", ["professor"])
    assert repr(candidato) == "Candidato(nome=João, cpf=12345678900)"


def test_candidato_profissoes():
    """Testa se as profissões do candidato são armazenadas corretamente."""
    candidato = Candidato("Maria", "1985-06-10", "98765432100", ["médico", "professor"])
    assert "médico" in candidato.profissoes
    assert "professor" in candidato.profissoes
