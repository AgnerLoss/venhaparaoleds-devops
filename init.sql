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
