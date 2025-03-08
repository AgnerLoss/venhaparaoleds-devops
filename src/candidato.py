import re
from datetime import datetime


class Candidato:
    def __init__(self, nome, data_nascimento, cpf, profissoes):
        # Validação do CPF com regex (11 dígitos numéricos obrigatórios)
        if not re.fullmatch(r"\d{11}", cpf):
            raise ValueError("CPF inválido")

        self.nome = nome
        self.data_nascimento = data_nascimento  # Agora padronizada no formato correto
        self.cpf = cpf
        self.profissoes = profissoes

    def __repr__(self):
        return f"Candidato(nome={self.nome}, cpf={self.cpf})"

    @classmethod
    def de_linha(cls, linha: str):
        """Converte uma linha de string para um objeto Candidato."""
        dados = linha.strip().split("\t")

        # Corrigindo o formato da data para YYYY-MM-DD
        data_nascimento = datetime.strptime(dados[1], "%d/%m/%Y").strftime("%Y-%m-%d")

        # Processar a lista de profissões manualmente
        profissoes = [prof.strip() for prof in dados[3].strip("[]").replace("'", "").replace('"', "").split(",")]

        return cls(dados[0], data_nascimento, dados[2], profissoes)

    def corresponde_ao_concurso(self, vagas: list) -> bool:
        """Verifica se o candidato possui uma profissão compatível com o concurso."""
        if not vagas or not self.profissoes:
            return False
        return any(profissao.strip().lower() in [vaga.strip().lower() for vaga in vagas] for profissao in self.profissoes)
