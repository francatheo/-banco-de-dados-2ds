-- ============================================================
-- BANCO DE DADOS ESCOLA - Script de Criação (SQLite)
-- Data: 2026-02-25
-- Descrição: Criação da estrutura do banco de dados e tabelas
-- ============================================================

-- ============================================================
-- TABELAS PRINCIPAIS
-- ============================================================

-- 1. Tabela de Usuários (para futura autenticação)
CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    senha TEXT,
    tipo_usuario TEXT NOT NULL CHECK(tipo_usuario IN ('aluno', 'professor', 'admin')),
    ativo INTEGER DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de Alunos
CREATE TABLE IF NOT EXISTS alunos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL,
    matricula TEXT UNIQUE NOT NULL,
    data_nascimento DATE,
    cpf TEXT UNIQUE,
    telefone TEXT,
    endereco TEXT,
    cidade TEXT,
    estado TEXT,
    data_matricula DATE NOT NULL,
    situacao TEXT DEFAULT 'ativo' CHECK(situacao IN ('ativo', 'inativo', 'transferido', 'formado')),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 3. Tabela de Professores
CREATE TABLE IF NOT EXISTS professores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL,
    siape TEXT UNIQUE NOT NULL,
    data_nascimento DATE,
    cpf TEXT UNIQUE,
    telefone TEXT,
    data_admissao DATE NOT NULL,
    departamento TEXT,
    ativo INTEGER DEFAULT 1,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 4. Tabela de Turmas
CREATE TABLE IF NOT EXISTS turmas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    serie INTEGER NOT NULL,
    ano_letivo INTEGER NOT NULL,
    semestre INTEGER DEFAULT 1,
    professor_orientador_id INTEGER,
    sala TEXT,
    capacidade INTEGER DEFAULT 30,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (professor_orientador_id) REFERENCES professores(id) ON DELETE SET NULL,
    UNIQUE(nome, ano_letivo, semestre)
);

-- 5. Tabela de Disciplinas
CREATE TABLE IF NOT EXISTS disciplinas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    codigo TEXT UNIQUE NOT NULL,
    descricao TEXT,
    carga_horaria INTEGER NOT NULL,
    serie INTEGER NOT NULL,
    ativa INTEGER DEFAULT 1
);

-- 6. Tabela de Aulas (Disciplinas por Turma)
CREATE TABLE IF NOT EXISTS aulas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    turma_id INTEGER NOT NULL,
    disciplina_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    dias_semana TEXT,
    horario_inicio TIME,
    horario_fim TIME,
    sala TEXT,
    data_inicio DATE,
    data_fim DATE,
    FOREIGN KEY (turma_id) REFERENCES turmas(id) ON DELETE CASCADE,
    FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id) ON DELETE RESTRICT,
    FOREIGN KEY (professor_id) REFERENCES professores(id) ON DELETE RESTRICT
);

-- 7. Tabela de Matrículas (Alunos em Turmas)
CREATE TABLE IF NOT EXISTS matriculas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aluno_id INTEGER NOT NULL,
    turma_id INTEGER NOT NULL,
    data_matricula DATE NOT NULL,
    situacao TEXT DEFAULT 'ativa' CHECK(situacao IN ('ativa', 'cancelada', 'trancada')),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE,
    FOREIGN KEY (turma_id) REFERENCES turmas(id) ON DELETE CASCADE,
    UNIQUE(aluno_id, turma_id)
);

-- 8. Tabela de Avaliações
CREATE TABLE IF NOT EXISTS avaliacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    aula_id INTEGER NOT NULL,
    tipo TEXT NOT NULL CHECK(tipo IN ('prova', 'trabalho', 'participacao', 'projeto')),
    descricao TEXT,
    data_avaliacao DATE,
    valor_maximo REAL DEFAULT 10.0,
    FOREIGN KEY (aula_id) REFERENCES aulas(id) ON DELETE CASCADE
);

-- 9. Tabela de Notas
CREATE TABLE IF NOT EXISTS notas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    matricula_id INTEGER NOT NULL,
    avaliacao_id INTEGER NOT NULL,
    nota REAL,
    data_lancamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT,
    FOREIGN KEY (matricula_id) REFERENCES matriculas(id) ON DELETE CASCADE,
    FOREIGN KEY (avaliacao_id) REFERENCES avaliacoes(id) ON DELETE CASCADE,
    UNIQUE(matricula_id, avaliacao_id)
);

-- 10. Tabela de Frequência
CREATE TABLE IF NOT EXISTS frequencias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    matricula_id INTEGER NOT NULL,
    aula_id INTEGER NOT NULL,
    data_aula DATE NOT NULL,
    presente INTEGER DEFAULT 0,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (matricula_id) REFERENCES matriculas(id) ON DELETE CASCADE,
    FOREIGN KEY (aula_id) REFERENCES aulas(id) ON DELETE CASCADE
);

-- 11. Tabela de Boletins (Relatório de Desempenho)
CREATE TABLE IF NOT EXISTS boletins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    matricula_id INTEGER NOT NULL,
    ano_letivo INTEGER NOT NULL,
    semestre INTEGER NOT NULL,
    media_final REAL,
    frequencia_percentual REAL,
    situacao TEXT DEFAULT 'aprovado' CHECK(situacao IN ('aprovado', 'reprovado', 'em_prova_final')),
    data_geracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (matricula_id) REFERENCES matriculas(id) ON DELETE CASCADE
);

-- ============================================================
-- ÍNDICES PARA OTIMIZAÇÃO DE CONSULTAS
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_alunos_usuario ON alunos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_alunos_matricula ON alunos(matricula);
CREATE INDEX IF NOT EXISTS idx_professores_usuario ON professores(usuario_id);
CREATE INDEX IF NOT EXISTS idx_turmas_ano ON turmas(ano_letivo);
CREATE INDEX IF NOT EXISTS idx_aulas_turma ON aulas(turma_id);
CREATE INDEX IF NOT EXISTS idx_aulas_professor ON aulas(professor_id);
CREATE INDEX IF NOT EXISTS idx_matriculas_aluno ON matriculas(aluno_id);
CREATE INDEX IF NOT EXISTS idx_matriculas_turma ON matriculas(turma_id);
CREATE INDEX IF NOT EXISTS idx_notas_matricula ON notas(matricula_id);
CREATE INDEX IF NOT EXISTS idx_frequencias_matricula ON frequencias(matricula_id);
CREATE INDEX IF NOT EXISTS idx_boletins_matricula ON boletins(matricula_id);

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
