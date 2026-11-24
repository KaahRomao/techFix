-- TechFix | SQLite 3.37 ou superior
-- Execute o arquivo inteiro em um banco vazio.
-- Os valores monetários são registrados em centavos.
-- Ative as chaves estrangeiras e os gatilhos recursivos em cada conexão.

PRAGMA foreign_keys = ON;
PRAGMA recursive_triggers = ON;

BEGIN;

-- Tabelas
CREATE TABLE cargo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_cargo TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1
) STRICT;

CREATE TABLE funcionario (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_funcionario TEXT NOT NULL COLLATE NOCASE,
    id_cargo INTEGER NOT NULL,
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_cargo) REFERENCES cargo(id) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE (id, id_cargo)
) STRICT;

CREATE TABLE cliente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_cliente TEXT NOT NULL COLLATE NOCASE,
    email TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1 OR id_funcionario_cargo = 2),
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo)
) STRICT;

CREATE TABLE categoria (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_categoria TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo)
) STRICT;

CREATE TABLE servico (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_servico TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_categoria INTEGER NOT NULL,
    preco INTEGER NOT NULL CHECK (preco >= 0),
    horas_trabalho REAL NOT NULL,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id)
) STRICT;

CREATE TABLE peca (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_peca TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_categoria INTEGER NOT NULL,
    preco_sugerido INTEGER NOT NULL CHECK (preco_sugerido >= 0),
    estoque_real INTEGER NOT NULL DEFAULT 0 CHECK (estoque_real >= 0),
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id)
) STRICT;

CREATE TABLE marca (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_marca TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1 OR id_funcionario_cargo = 2),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo)
) STRICT;

CREATE TABLE modelo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_modelo TEXT NOT NULL COLLATE NOCASE,
    id_marca INTEGER NOT NULL,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1 OR id_funcionario_cargo = 2),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_marca) REFERENCES marca(id),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo),
    UNIQUE (id_marca, nome_modelo),
    UNIQUE (id, id_marca)
) STRICT;

CREATE TABLE tipo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_tipo TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1 OR id_funcionario_cargo = 2),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo)
) STRICT;

CREATE TABLE equipamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tipo INTEGER NOT NULL,
    id_marca INTEGER NOT NULL,
    id_modelo INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    numero_serie TEXT COLLATE NOCASE,
    imei TEXT COLLATE NOCASE UNIQUE,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1 OR id_funcionario_cargo = 2),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_tipo) REFERENCES tipo(id),
    FOREIGN KEY (id_modelo, id_marca) REFERENCES modelo(id, id_marca),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo),
    CHECK (NULLIF(TRIM(numero_serie), '') IS NOT NULL OR NULLIF(TRIM(imei), '') IS NOT NULL)
) STRICT;

CREATE TABLE situacao (
    id INTEGER PRIMARY KEY CHECK (id BETWEEN 1 AND 7),
    nome_situacao TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    CHECK (nome_situacao COLLATE BINARY = CASE id
        WHEN 1 THEN 'Aberto'
        WHEN 2 THEN 'Em Diagnóstico'
        WHEN 3 THEN 'Orçamento Aprovado'
        WHEN 4 THEN 'Em Reparo'
        WHEN 5 THEN 'Pronto'
        WHEN 6 THEN 'Entregue'
        WHEN 7 THEN 'Cancelado'
    END)
) STRICT;

CREATE TABLE forma_pagamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_forma_pagamento TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1 OR id_funcionario_cargo = 2),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo)
) STRICT;

CREATE TABLE ordem (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_equipamento INTEGER NOT NULL,
    defeito_relatado TEXT NOT NULL COLLATE NOCASE,
    defeito_constatado TEXT DEFAULT('') COLLATE NOCASE,
    data_abertura TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    id_situacao_atual INTEGER NOT NULL DEFAULT 1,
    data_fechamento TEXT,
    valor_total INTEGER NOT NULL DEFAULT 0 CHECK (valor_total >= 0),
    id_forma_pagamento INTEGER,
    id_funcionario_abertura INTEGER NOT NULL,
    id_funcionario_cargo_abertura INTEGER NOT NULL CHECK (
        id_funcionario_cargo_abertura = 1
        OR id_funcionario_cargo_abertura = 2
    ),
    id_tecnico INTEGER NOT NULL,
    id_tecnico_cargo INTEGER NOT NULL CHECK (id_tecnico_cargo = 3),
    FOREIGN KEY (id_situacao_atual) REFERENCES situacao(id),
    FOREIGN KEY (id_equipamento) REFERENCES equipamento(id),
    FOREIGN KEY (id_forma_pagamento) REFERENCES forma_pagamento(id),
    FOREIGN KEY (id_funcionario_abertura, id_funcionario_cargo_abertura) REFERENCES funcionario(id, id_cargo),
    FOREIGN KEY (id_tecnico, id_tecnico_cargo) REFERENCES funcionario(id, id_cargo),
    UNIQUE (id, id_tecnico, id_tecnico_cargo),
    CHECK (strftime('%Y-%m-%d %H:%M:%S', data_abertura, '+0 seconds') IS data_abertura)
) STRICT;

CREATE TABLE ordem_servico (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_ordem INTEGER NOT NULL,
    id_servico INTEGER NOT NULL,
    quantidade_servico INTEGER NOT NULL CHECK (quantidade_servico > 0),
    valor_unitario INTEGER NOT NULL CHECK (valor_unitario >= 0),
    data_execucao TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_ordem) REFERENCES ordem(id),
    FOREIGN KEY (id_servico) REFERENCES servico(id),
    CHECK (strftime('%Y-%m-%d %H:%M:%S', data_execucao, '+0 seconds') IS data_execucao)
) STRICT;

CREATE TABLE ordem_situacao (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_ordem INTEGER NOT NULL,
    id_nova_situacao INTEGER NOT NULL DEFAULT 1,
    id_tecnico INTEGER NOT NULL,
    id_tecnico_cargo INTEGER NOT NULL CHECK (id_tecnico_cargo = 3),
    data_situacao TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_ordem) REFERENCES ordem(id),
    FOREIGN KEY (id_nova_situacao) REFERENCES situacao(id),
    FOREIGN KEY (id_ordem, id_tecnico, id_tecnico_cargo) REFERENCES ordem(id, id_tecnico, id_tecnico_cargo),
    CHECK (strftime('%Y-%m-%d %H:%M:%S', data_situacao, '+0 seconds') IS data_situacao)
) STRICT;

CREATE TABLE ordem_peca (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_ordem INTEGER NOT NULL,
    id_peca INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    valor_unitario INTEGER NOT NULL CHECK (valor_unitario >= 0),
    id_tecnico INTEGER NOT NULL,
    id_tecnico_cargo INTEGER NOT NULL CHECK (id_tecnico_cargo = 3),
    data_saida TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_peca) REFERENCES peca(id),
    FOREIGN KEY (id_ordem, id_tecnico, id_tecnico_cargo) REFERENCES ordem(id, id_tecnico, id_tecnico_cargo),
    CHECK (strftime('%Y-%m-%d %H:%M:%S', data_saida, '+0 seconds') IS data_saida)
) STRICT;

CREATE TABLE entrada_peca (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_peca INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_de_compra INTEGER NOT NULL CHECK (preco_de_compra >= 0),
    preco_sugerido_venda INTEGER NOT NULL CHECK (preco_sugerido_venda >= 0),
    id_funcionario INTEGER NOT NULL,
    id_funcionario_cargo INTEGER NOT NULL CHECK (id_funcionario_cargo = 1),
    status INTEGER NOT NULL DEFAULT 1,
    data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_peca) REFERENCES peca(id),
    FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo)
) STRICT;

CREATE TABLE saida_peca (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_peca INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    motivo TEXT NOT NULL CHECK (motivo IN ('defeito', 'avaria')),
    preco_de_compra INTEGER NOT NULL CHECK (preco_de_compra >= 0),
    id_tecnico INTEGER NOT NULL,
    id_tecnico_cargo INTEGER NOT NULL CHECK (id_tecnico_cargo = 3),
    data_saida TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
    FOREIGN KEY (id_peca) REFERENCES peca(id),
    FOREIGN KEY (id_tecnico, id_tecnico_cargo) REFERENCES funcionario(id, id_cargo)
) STRICT;

CREATE TABLE ordem_pagamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_ordem INTEGER NOT NULL UNIQUE,
    id_forma_pagamento INTEGER NOT NULL,
    valor INTEGER NOT NULL CHECK (valor > 0),
    data_pagamento TEXT NOT NULL,
    FOREIGN KEY (id_ordem) REFERENCES ordem(id),
    FOREIGN KEY (id_forma_pagamento) REFERENCES forma_pagamento(id)
) STRICT;

-- Conferência dos saldos e valores pelos registros que lhes deram origem.
CREATE INDEX idx_entrada_peca_peca ON entrada_peca (id_peca);
CREATE INDEX idx_saida_peca_peca ON saida_peca (id_peca);
CREATE INDEX idx_ordem_peca_peca ON ordem_peca (id_peca);
CREATE INDEX idx_ordem_peca_ordem ON ordem_peca (id_ordem);
CREATE INDEX idx_ordem_servico_ordem ON ordem_servico (id_ordem);
CREATE INDEX idx_ordem_situacao_ordem ON ordem_situacao (id_ordem, id DESC);

CREATE VIEW vw_saldo_peca AS
SELECT peca.id AS id_peca,
    COALESCE((SELECT SUM(quantidade) FROM entrada_peca WHERE id_peca = peca.id), 0)
    - COALESCE((SELECT SUM(quantidade) FROM ordem_peca WHERE id_peca = peca.id), 0)
    - COALESCE((SELECT SUM(quantidade) FROM saida_peca WHERE id_peca = peca.id), 0) AS estoque_calculado
FROM peca;

CREATE VIEW vw_total_ordem AS
SELECT ordem.id AS id_ordem,
    COALESCE((
        SELECT SUM(quantidade_servico * valor_unitario) FROM ordem_servico WHERE id_ordem = ordem.id
    ), 0)
    + COALESCE((
        SELECT SUM(quantidade * valor_unitario) FROM ordem_peca WHERE id_ordem = ordem.id
    ), 0) AS total_calculado
FROM ordem;

-- Peças a partir de R$ 100.
CREATE VIEW vw_preco_sugerido_maior_100 AS
SELECT id, nome_peca, preco_sugerido, estoque_real
FROM peca
WHERE preco_sugerido >= 10000;

-- Gatilhos de situação. 1 = Aberto, 6 = Entregue, 7 = Cancelado.

CREATE TRIGGER trg_bi_ordem_valida_abertura
BEFORE INSERT ON ordem
WHEN NEW.id_situacao_atual <> 1 OR NEW.data_fechamento IS NOT NULL OR NEW.valor_total <> 0
BEGIN
    SELECT RAISE(ABORT, 'A ordem deve iniciar aberta e com valor total zero.');
END;

CREATE TRIGGER trg_ai_ordem_registra_situacao_inicial
AFTER INSERT ON ordem
BEGIN
    INSERT INTO ordem_situacao (id_ordem, id_nova_situacao, id_tecnico, id_tecnico_cargo, data_situacao)
    VALUES (NEW.id, NEW.id_situacao_atual, NEW.id_tecnico, NEW.id_tecnico_cargo, NEW.data_abertura);
END;

CREATE TRIGGER trg_bi_ordem_situacao_valida_ordem_aberta
BEFORE INSERT ON ordem_situacao
BEGIN
    SELECT RAISE(ABORT, 'Ordem já encerrada.')
    WHERE EXISTS (SELECT 1 FROM ordem WHERE id = NEW.id_ordem AND data_fechamento IS NOT NULL);

    SELECT RAISE(ABORT, 'Situação inativa ou inexistente.')
    WHERE (SELECT status FROM situacao WHERE id = NEW.id_nova_situacao) IS NOT 1;

    SELECT RAISE(ABORT, 'A data da situação deve respeitar a ordem do histórico.')
    WHERE NEW.data_situacao < COALESCE(
        (SELECT data_situacao FROM ordem_situacao WHERE id_ordem = NEW.id_ordem ORDER BY id DESC LIMIT 1),
        (SELECT data_abertura FROM ordem WHERE id = NEW.id_ordem)
    );

    SELECT RAISE(ABORT, 'O encerramento não pode anteceder um serviço ou uma baixa da ordem.')
    WHERE NEW.id_nova_situacao IN (6, 7)
      AND (
          EXISTS (SELECT 1 FROM ordem_servico WHERE id_ordem = NEW.id_ordem AND data_execucao > NEW.data_situacao)
          OR EXISTS (SELECT 1 FROM ordem_peca WHERE id_ordem = NEW.id_ordem AND data_saida > NEW.data_situacao)
      );

    SELECT RAISE(ABORT, 'Escolha uma forma de pagamento ativa antes da entrega.')
    WHERE NEW.id_nova_situacao = 6
      AND EXISTS (
          SELECT 1
          FROM ordem
          LEFT JOIN forma_pagamento ON forma_pagamento.id = ordem.id_forma_pagamento
          WHERE ordem.id = NEW.id_ordem AND ordem.valor_total > 0 AND forma_pagamento.status IS NOT 1
      );
END;

CREATE TRIGGER trg_ai_ordem_situacao_atualiza_ordem
AFTER INSERT ON ordem_situacao
BEGIN
    UPDATE ordem
    SET id_situacao_atual = NEW.id_nova_situacao,
        data_fechamento = CASE WHEN NEW.id_nova_situacao IN (6, 7) THEN NEW.data_situacao END,
        id_forma_pagamento = CASE
            WHEN NEW.id_nova_situacao = 7 OR (NEW.id_nova_situacao = 6 AND valor_total = 0) THEN NULL
            ELSE id_forma_pagamento
        END
    WHERE id = NEW.id_ordem;

    INSERT INTO ordem_pagamento (id_ordem, id_forma_pagamento, valor, data_pagamento)
    SELECT id, id_forma_pagamento, valor_total, data_fechamento
    FROM ordem
    WHERE id = NEW.id_ordem AND NEW.id_nova_situacao = 6 AND valor_total > 0;
END;

CREATE TRIGGER trg_bu_ordem_preserva_situacao
BEFORE UPDATE OF id_situacao_atual, data_fechamento ON ordem
WHEN (NEW.id_situacao_atual, NEW.data_fechamento) IS NOT (
    SELECT id_nova_situacao,
           CASE WHEN id_nova_situacao IN (6, 7) THEN data_situacao END
    FROM ordem_situacao
    WHERE id_ordem = OLD.id
    ORDER BY id DESC
    LIMIT 1
)
BEGIN
    SELECT RAISE(ABORT, 'Registre a mudança de situação em ordem_situacao.');
END;

CREATE TRIGGER trg_bu_ordem_preserva_data_abertura
BEFORE UPDATE OF data_abertura ON ordem
WHEN NEW.data_abertura IS NOT OLD.data_abertura
BEGIN
    SELECT RAISE(ABORT, 'A data de abertura da ordem já está registrada no histórico.');
END;

CREATE TRIGGER trg_bu_ordem_preserva_valor_total
BEFORE UPDATE OF valor_total ON ordem
WHEN NEW.valor_total IS NOT (SELECT total_calculado FROM vw_total_ordem WHERE id_ordem = OLD.id)
BEGIN
    SELECT RAISE(ABORT, 'O valor total é calculado pelos serviços e peças da ordem.');
END;

CREATE TRIGGER trg_bu_ordem_preserva_forma_pagamento
BEFORE UPDATE OF id_forma_pagamento ON ordem
WHEN OLD.data_fechamento IS NOT NULL AND NEW.id_forma_pagamento IS NOT OLD.id_forma_pagamento
BEGIN
    SELECT RAISE(ABORT, 'A forma de pagamento de uma ordem encerrada não pode ser alterada.');
END;

CREATE TRIGGER trg_bu_ordem_situacao_preserva_historico
BEFORE UPDATE ON ordem_situacao
BEGIN
    SELECT RAISE(ABORT, 'O histórico de situações não pode ser alterado.');
END;

CREATE TRIGGER trg_bd_ordem_situacao_preserva_historico
BEFORE DELETE ON ordem_situacao
BEGIN
    SELECT RAISE(ABORT, 'O histórico de situações não pode ser excluído.');
END;

-- O histórico de entrega gera o pagamento na mesma transação.
CREATE TRIGGER trg_bi_ordem_pagamento_valida
BEFORE INSERT ON ordem_pagamento
WHEN NOT EXISTS (
    SELECT 1 FROM ordem
    WHERE id = NEW.id_ordem AND id_situacao_atual = 6
      AND (id_forma_pagamento, valor_total, data_fechamento) =
          (NEW.id_forma_pagamento, NEW.valor, NEW.data_pagamento)
)
BEGIN
    SELECT RAISE(ABORT, 'O pagamento deve corresponder ao fechamento da ordem entregue.');
END;

CREATE TRIGGER trg_bu_ordem_pagamento_preserva
BEFORE UPDATE ON ordem_pagamento
BEGIN
    SELECT RAISE(ABORT, 'O pagamento registrado no fechamento não pode ser alterado.');
END;

CREATE TRIGGER trg_bd_ordem_pagamento_preserva
BEFORE DELETE ON ordem_pagamento
BEGIN
    SELECT RAISE(ABORT, 'O pagamento registrado no fechamento não pode ser excluído.');
END;

-- Serviços. O valor unitário registrado no item preserva o preço da operação.
CREATE TRIGGER trg_bi_ordem_servico_valida
BEFORE INSERT ON ordem_servico
BEGIN
    SELECT RAISE(ABORT, 'Ordem encerrada.')
    WHERE EXISTS (SELECT 1 FROM ordem WHERE id = NEW.id_ordem AND data_fechamento IS NOT NULL);

    SELECT RAISE(ABORT, 'Serviço inativo ou inexistente.')
    WHERE (SELECT status FROM servico WHERE id = NEW.id_servico) IS NOT 1;

    SELECT RAISE(ABORT, 'A execução não pode anteceder a abertura da ordem.')
    WHERE NEW.data_execucao < (SELECT data_abertura FROM ordem WHERE id = NEW.id_ordem);
END;

CREATE TRIGGER trg_bu_ordem_servico_valida
BEFORE UPDATE ON ordem_servico
BEGIN
    SELECT RAISE(ABORT, 'Ordem encerrada.')
    WHERE EXISTS (
        SELECT 1 FROM ordem WHERE id IN (OLD.id_ordem, NEW.id_ordem) AND data_fechamento IS NOT NULL
    );

    SELECT RAISE(ABORT, 'A ordem, o serviço, a data e o preço da execução já foram registrados.')
    WHERE (NEW.id_ordem, NEW.id_servico, NEW.data_execucao, NEW.valor_unitario) IS NOT
          (OLD.id_ordem, OLD.id_servico, OLD.data_execucao, OLD.valor_unitario);
END;

CREATE TRIGGER trg_bd_ordem_servico_valida
BEFORE DELETE ON ordem_servico
WHEN EXISTS (SELECT 1 FROM ordem WHERE id = OLD.id_ordem AND data_fechamento IS NOT NULL)
BEGIN
    SELECT RAISE(ABORT, 'Ordem encerrada.');
END;

CREATE TRIGGER trg_ai_ordem_servico_atualiza_valor_total_ordem
AFTER INSERT ON ordem_servico
BEGIN
    UPDATE ordem
    SET valor_total = valor_total + NEW.valor_unitario * NEW.quantidade_servico
    WHERE id = NEW.id_ordem;
END;

CREATE TRIGGER trg_au_ordem_servico_atualiza_valor_total_ordem
AFTER UPDATE OF quantidade_servico ON ordem_servico
BEGIN
    UPDATE ordem
    SET valor_total = valor_total + (NEW.quantidade_servico - OLD.quantidade_servico) * OLD.valor_unitario
    WHERE id = OLD.id_ordem;
END;

CREATE TRIGGER trg_ad_ordem_servico_atualiza_valor_total_ordem
AFTER DELETE ON ordem_servico
BEGIN
    UPDATE ordem
    SET valor_total = valor_total - OLD.valor_unitario * OLD.quantidade_servico
    WHERE id = OLD.id_ordem;
END;

-- Peças da ordem. A baixa exige orçamento aprovado (3) ou reparo em andamento (4).
CREATE TRIGGER trg_bi_ordem_peca_valida_estoque
BEFORE INSERT ON ordem_peca
BEGIN
    SELECT RAISE(ABORT, 'Ordem encerrada: não é possível adicionar peças.')
    WHERE EXISTS (SELECT 1 FROM ordem WHERE id = NEW.id_ordem AND data_fechamento IS NOT NULL);

    SELECT RAISE(ABORT, 'Peça inativa ou inexistente.')
    WHERE (SELECT status FROM peca WHERE id = NEW.id_peca) IS NOT 1;

    SELECT RAISE(ABORT, 'Estoque insuficiente para a quantidade solicitada.')
    WHERE (SELECT estoque_real FROM peca WHERE id = NEW.id_peca) < NEW.quantidade;

    SELECT RAISE(ABORT, 'A baixa exige uma ordem com orçamento aprovado ou em reparo.')
    WHERE (SELECT id_situacao_atual FROM ordem WHERE id = NEW.id_ordem) NOT IN (3, 4);

    SELECT RAISE(ABORT, 'A baixa não pode anteceder a situação atual da ordem.')
    WHERE NEW.data_saida < (
        SELECT data_situacao FROM ordem_situacao WHERE id_ordem = NEW.id_ordem ORDER BY id DESC LIMIT 1
    );
END;

CREATE TRIGGER trg_bu_ordem_peca_valida
BEFORE UPDATE ON ordem_peca
BEGIN
    SELECT RAISE(ABORT, 'Ordem encerrada.')
    WHERE EXISTS (SELECT 1 FROM ordem WHERE id = OLD.id_ordem AND data_fechamento IS NOT NULL);

    SELECT RAISE(ABORT, 'Não é permitido trocar ordem ou peça; exclua e insira novamente.')
    WHERE NEW.id_ordem <> OLD.id_ordem OR NEW.id_peca <> OLD.id_peca;

    SELECT RAISE(ABORT, 'A data e o preço da peça já foram registrados.')
    WHERE (NEW.data_saida, NEW.valor_unitario) IS NOT (OLD.data_saida, OLD.valor_unitario);

    SELECT RAISE(ABORT, 'Peça inativa ou inexistente.')
    WHERE NEW.quantidade > OLD.quantidade
      AND (SELECT status FROM peca WHERE id = NEW.id_peca) IS NOT 1;

    SELECT RAISE(ABORT, 'Estoque insuficiente.')
    WHERE (SELECT estoque_real FROM peca WHERE id = NEW.id_peca) + OLD.quantidade < NEW.quantidade;

    SELECT RAISE(ABORT, 'A baixa exige uma ordem com orçamento aprovado ou em reparo.')
    WHERE NEW.quantidade > OLD.quantidade
      AND (SELECT id_situacao_atual FROM ordem WHERE id = NEW.id_ordem) NOT IN (3, 4);
END;

CREATE TRIGGER trg_bd_ordem_peca_valida
BEFORE DELETE ON ordem_peca
WHEN EXISTS (SELECT 1 FROM ordem WHERE id = OLD.id_ordem AND data_fechamento IS NOT NULL)
BEGIN
    SELECT RAISE(ABORT, 'Ordem encerrada.');
END;

CREATE TRIGGER trg_ai_ordem_peca_baixa_estoque_soma_total
AFTER INSERT ON ordem_peca
BEGIN
    UPDATE peca SET estoque_real = estoque_real - NEW.quantidade WHERE id = NEW.id_peca;

    UPDATE ordem
    SET valor_total = valor_total + NEW.quantidade * NEW.valor_unitario
    WHERE id = NEW.id_ordem;
END;

CREATE TRIGGER trg_au_ordem_peca_ajusta_estoque_total
AFTER UPDATE OF quantidade ON ordem_peca
BEGIN
    UPDATE peca SET estoque_real = estoque_real + OLD.quantidade - NEW.quantidade
    WHERE id = NEW.id_peca;

    UPDATE ordem
    SET valor_total = valor_total + (NEW.quantidade - OLD.quantidade) * OLD.valor_unitario
    WHERE id = NEW.id_ordem;
END;

CREATE TRIGGER trg_ad_ordem_peca_devolve_estoque_subtrai_total
AFTER DELETE ON ordem_peca
BEGIN
    UPDATE peca SET estoque_real = estoque_real + OLD.quantidade WHERE id = OLD.id_peca;

    UPDATE ordem
    SET valor_total = valor_total - OLD.quantidade * OLD.valor_unitario
    WHERE id = OLD.id_ordem;
END;

-- Movimentos avulsos. Um estorno só pode retirar unidades ainda em estoque.
CREATE TRIGGER trg_bi_peca_valida_estoque_inicial
BEFORE INSERT ON peca
WHEN NEW.estoque_real <> 0
BEGIN
    SELECT RAISE(ABORT, 'Registre o estoque inicial como uma entrada de peças.');
END;

CREATE TRIGGER trg_bu_peca_preserva_estoque
BEFORE UPDATE OF estoque_real ON peca
WHEN NEW.estoque_real IS NOT (SELECT estoque_calculado FROM vw_saldo_peca WHERE id_peca = OLD.id)
BEGIN
    SELECT RAISE(ABORT, 'Registre uma entrada, uma baixa na ordem ou um descarte para ajustar o estoque.');
END;

CREATE TRIGGER trg_ai_entrada_peca_soma_estoque
AFTER INSERT ON entrada_peca
BEGIN
    UPDATE peca SET estoque_real = estoque_real + NEW.quantidade WHERE id = NEW.id_peca;
END;

CREATE TRIGGER trg_bu_entrada_peca_valida_estorno
BEFORE UPDATE OF id_peca, quantidade ON entrada_peca
WHEN (SELECT estoque_real FROM peca WHERE id = OLD.id_peca)
     + (CASE WHEN NEW.id_peca = OLD.id_peca THEN NEW.quantidade ELSE 0 END) < OLD.quantidade
BEGIN
    SELECT RAISE(ABORT, 'Estoque insuficiente para estornar a entrada.');
END;

CREATE TRIGGER trg_au_entrada_peca_ajusta_estoque
AFTER UPDATE OF id_peca, quantidade ON entrada_peca
BEGIN
    UPDATE peca
    SET estoque_real = estoque_real
        - (CASE WHEN id = OLD.id_peca THEN OLD.quantidade ELSE 0 END)
        + (CASE WHEN id = NEW.id_peca THEN NEW.quantidade ELSE 0 END)
    WHERE id IN (OLD.id_peca, NEW.id_peca);
END;

CREATE TRIGGER trg_bd_entrada_peca_valida_estorno
BEFORE DELETE ON entrada_peca
WHEN (SELECT estoque_real FROM peca WHERE id = OLD.id_peca) < OLD.quantidade
BEGIN
    SELECT RAISE(ABORT, 'Estoque insuficiente para estornar a entrada.');
END;

CREATE TRIGGER trg_ad_entrada_peca_estorna_estoque
AFTER DELETE ON entrada_peca
BEGIN
    UPDATE peca SET estoque_real = estoque_real - OLD.quantidade WHERE id = OLD.id_peca;
END;

CREATE TRIGGER trg_bi_saida_peca_valida_estoque
BEFORE INSERT ON saida_peca
BEGIN
    SELECT RAISE(ABORT, 'Peça inativa ou inexistente.')
    WHERE (SELECT status FROM peca WHERE id = NEW.id_peca) IS NOT 1;

    SELECT RAISE(ABORT, 'Estoque insuficiente.')
    WHERE (SELECT estoque_real FROM peca WHERE id = NEW.id_peca) < NEW.quantidade;
END;

CREATE TRIGGER trg_bu_saida_peca_valida_estoque
BEFORE UPDATE OF id_peca, quantidade ON saida_peca
WHEN NEW.id_peca <> OLD.id_peca OR NEW.quantidade > OLD.quantidade
BEGIN
    SELECT RAISE(ABORT, 'Peça inativa ou inexistente.')
    WHERE (SELECT status FROM peca WHERE id = NEW.id_peca) IS NOT 1;

    SELECT RAISE(ABORT, 'Estoque insuficiente.')
    WHERE (SELECT estoque_real FROM peca WHERE id = NEW.id_peca)
          + (CASE WHEN NEW.id_peca = OLD.id_peca THEN OLD.quantidade ELSE 0 END) < NEW.quantidade;
END;

CREATE TRIGGER trg_ai_saida_peca_baixa_estoque
AFTER INSERT ON saida_peca
BEGIN
    UPDATE peca SET estoque_real = estoque_real - NEW.quantidade WHERE id = NEW.id_peca;
END;

CREATE TRIGGER trg_au_saida_peca_ajusta_estoque
AFTER UPDATE OF id_peca, quantidade ON saida_peca
BEGIN
    UPDATE peca
    SET estoque_real = estoque_real
        + (CASE WHEN id = OLD.id_peca THEN OLD.quantidade ELSE 0 END)
        - (CASE WHEN id = NEW.id_peca THEN NEW.quantidade ELSE 0 END)
    WHERE id IN (OLD.id_peca, NEW.id_peca);
END;

CREATE TRIGGER trg_ad_saida_peca_estorna_estoque
AFTER DELETE ON saida_peca
BEGIN
    UPDATE peca SET estoque_real = estoque_real + OLD.quantidade WHERE id = OLD.id_peca;
END;

CREATE TRIGGER trg_bd_cliente_bloqueia_delete
BEFORE DELETE ON cliente
BEGIN
    SELECT RAISE(ABORT, 'Exclusão física não permitida. Use status = 0.');
END;

-- Dados de exemplo do TechFix. A carga passa pelos mesmos gatilhos usados no dia a dia.

INSERT INTO cargo (id, nome_cargo, status) VALUES
    (1, 'Gerente', 1),
    (2, 'Atendente', 1),
    (3, 'Técnico', 1);

INSERT INTO funcionario (id, nome_funcionario, id_cargo, status, data_cadastro) VALUES
    (1, 'Carlos Andrade', 1, 1, '2026-08-20 09:00:00'),
    (2, 'Fernanda Souza', 2, 1, '2026-08-20 09:00:00'),
    (3, 'Rafael Lima', 2, 1, '2026-08-20 09:00:00'),
    (4, 'João Pereira', 3, 1, '2026-08-20 09:00:00'),
    (5, 'Marcos Vieira', 3, 1, '2026-08-20 09:00:00'),
    (6, 'Bruno Costa', 3, 1, '2026-08-20 09:00:00');

INSERT INTO cliente (id, nome_cliente, email, status, id_funcionario, id_funcionario_cargo, data_cadastro) VALUES
    (1, 'Marcos', 'marcos@example.com', 1, 3, 2, '2026-08-20 09:00:00'),
    (2, 'Ana Souza', 'ana@example.com', 1, 2, 2, '2026-08-20 09:00:00'),
    (3, 'Pedro Lima', 'pedro@example.com', 1, 3, 2, '2026-08-20 09:00:00');

INSERT INTO categoria (id, nome_categoria, id_funcionario, id_funcionario_cargo, status, data_cadastro) VALUES
    (1, 'computadores', 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 'celulares', 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 'smart tvs', 1, 1, 1, '2026-08-20 09:00:00'),
    (4, 'redes', 1, 1, 1, '2026-08-20 09:00:00'),
    (5, 'videogames', 1, 1, 1, '2026-08-20 09:00:00'),
    (6, 'áudio', 1, 1, 1, '2026-08-20 09:00:00'),
    (7, 'recuperação de dados', 1, 1, 1, '2026-08-20 09:00:00'),
    (8, 'eletrônica avançada', 1, 1, 1, '2026-08-20 09:00:00'),
    (9, 'informática', 1, 1, 1, '2026-08-20 09:00:00'),
    (10, 'insumos', 1, 1, 1, '2026-08-20 09:00:00'),
    (11, 'acessórios', 1, 1, 1, '2026-08-20 09:00:00'),
    (12, 'telas', 1, 1, 1, '2026-08-20 09:00:00'),
    (13, 'baterias', 1, 1, 1, '2026-08-20 09:00:00'),
    (14, 'componentes', 1, 1, 1, '2026-08-20 09:00:00'),
    (15, 'carcaças', 1, 1, 1, '2026-08-20 09:00:00'),
    (16, 'tvs', 1, 1, 1, '2026-08-20 09:00:00');

INSERT INTO servico (
    id, nome_servico, id_categoria, preco, horas_trabalho, id_funcionario, id_funcionario_cargo,
    status, data_cadastro
) VALUES
    (1, 'Formatação e Instalação de Sistema Operacional', 1, 12000, 2.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 'Limpeza Interna e Troca de Pasta Térmica', 1, 15000, 1.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 'Upgrade de Hardware (RAM/SSD)', 1, 8000, 1.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (4, 'Remoção de Vírus e Malwares', 1, 10000, 1.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (5, 'Troca de Tela de Notebook', 1, 18000, 1.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (6, 'Troca de Display/Frontal de Celular', 2, 15000, 1.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (7, 'Troca de Bateria de Smartphone', 2, 9000, 0.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (8, 'Desoxidação após Contato com Líquido', 2, 20000, 3.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (9, 'Reparo em Conector de Carga (Micro USB / Type-C)', 2, 11000, 1.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (10, 'Troca de Vidro Traseiro de Smartphone a Laser / Manual', 2, 18000, 2.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (11, 'Troca de Barra de LED de Smart TV', 3, 35000, 3.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (12, 'Reparo na Placa Principal de Smart TV', 3, 28000, 2.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (13, 'Conserto de Fonte de Alimentação Interna (TV)', 3, 22000, 2.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (14, 'Configuração de Rede e Roteador Wi-Fi', 4, 9000, 1.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (15, 'Higienização e Troca de Metal Líquido / Pasta Térmica (Console)', 5, 22000, 2.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (16, 'Reparo de Drift em Analógico de Controle (Joy-Con / DualSense / Xbox)', 5, 8000, 1.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (17, 'Substituição de HDMI / Conector de Vídeo (Console)', 5, 25000, 2.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (18, 'Troca de Bateria de Caixa de Som Portátil (Bluetooth)', 6, 12000, 1.5, 1, 1, 1, '2026-08-20 09:00:00'),
    (19, 'Troca de Almofadas / Reparo de Cabo de Headset Gamer', 6, 7000, 1.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (20, 'Reparo e Solda de Conector Jack P2/P10 de Mesa de Som ou Amplificador', 6, 9500, 1.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (21, 'Recuperação de Dados de HD / SSD / Pendrive Danificado', 7, 30000, 4.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (22, 'Rebaling / Reparo de BGA em Placa Mãe ou Placa de Vídeo', 8, 45000, 5.0, 1, 1, 1, '2026-08-20 09:00:00'),
    (23, 'Gravação e Reprogramação de BIOS Eprom (Notebook / Desktop)', 8, 16000, 2.0, 1, 1, 1, '2026-08-20 09:00:00');

INSERT INTO peca (
    id, nome_peca, id_categoria, preco_sugerido, id_funcionario, id_funcionario_cargo, status,
    data_cadastro
) VALUES
    (1, 'SSD NVMe 512GB M.2', 9, 26000, 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 'SSD SATA III 480GB 2.5"', 9, 21000, 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 'Memória RAM DDR4 8GB 2666MHz (Notebook)', 9, 17000, 1, 1, 1, '2026-08-20 09:00:00'),
    (4, 'Memória RAM DDR4 16GB 3200MHz (Desktop)', 9, 32000, 1, 1, 1, '2026-08-20 09:00:00'),
    (5, 'Pasta Térmica de Alta Performance (Bisnaga 4g)', 10, 6000, 1, 1, 1, '2026-08-20 09:00:00'),
    (6, 'Fonte ATX 500W 80 Plus Bronze', 9, 34000, 1, 1, 1, '2026-08-20 09:00:00'),
    (7, 'Bateria Célula Moeda CR2032 (Cartela c/ 5)', 10, 2500, 1, 1, 1, '2026-08-20 09:00:00'),
    (8, 'Cooler para Processador Socket Universal', 9, 9500, 1, 1, 1, '2026-08-20 09:00:00'),
    (9, 'Cabo SATA III 6Gbps 50cm', 11, 1500, 1, 1, 1, '2026-08-20 09:00:00'),
    (10, 'Tela LED 15.6" Slim 30 Pinos Full HD', 12, 48000, 1, 1, 1, '2026-08-20 09:00:00'),
    (11, 'Display Frontal Completo iPhone 11', 12, 35000, 1, 1, 1, '2026-08-20 09:00:00'),
    (12, 'Display Frontal Completo Samsung Galaxy A54', 12, 31000, 1, 1, 1, '2026-08-20 09:00:00'),
    (13, 'Display Frontal Completo Motorola Moto G84', 12, 28000, 1, 1, 1, '2026-08-20 09:00:00'),
    (14, 'Bateria Compatível iPhone 11 (3110mAh)', 13, 16000, 1, 1, 1, '2026-08-20 09:00:00'),
    (15, 'Bateria Compatível Samsung Galaxy A32', 13, 13000, 1, 1, 1, '2026-08-20 09:00:00'),
    (16, 'Bateria Compatível Moto G30', 13, 12000, 1, 1, 1, '2026-08-20 09:00:00'),
    (17, 'Conector de Carga Type-C Universal (Unidade)', 14, 2000, 1, 1, 1, '2026-08-20 09:00:00'),
    (18, 'Conector de Carga Micro USB V8', 14, 1500, 1, 1, 1, '2026-08-20 09:00:00'),
    (19, 'Flex de Carga e Microfone Moto G9 Play', 14, 5500, 1, 1, 1, '2026-08-20 09:00:00'),
    (20, 'Tampa Traseira de Vidro iPhone 12', 15, 11000, 1, 1, 1, '2026-08-20 09:00:00'),
    (21, 'Câmera Traseira Principal Redmi Note 11', 14, 14000, 1, 1, 1, '2026-08-20 09:00:00'),
    (22, 'Alto-Falante Auricular Universal', 14, 2500, 1, 1, 1, '2026-08-20 09:00:00'),
    (23, 'Barra de LED TV Samsung 50" (Kit com 3 barras)', 16, 23000, 1, 1, 1, '2026-08-20 09:00:00'),
    (24, 'Barra de LED TV LG 43" (Kit com 3 barras)', 16, 19500, 1, 1, 1, '2026-08-20 09:00:00'),
    (25, 'Placa Fonte TV Samsung UN50TU8000', 16, 31000, 1, 1, 1, '2026-08-20 09:00:00'),
    (26, 'Placa Principal TV LG 43UP7500', 16, 42000, 1, 1, 1, '2026-08-20 09:00:00'),
    (27, 'Cabo Flat T-Con para Display TV 55"', 16, 6500, 1, 1, 1, '2026-08-20 09:00:00'),
    (28, 'Receptor Infravermelho para Controle Remoto TV', 14, 2000, 1, 1, 1, '2026-08-20 09:00:00'),
    (29, 'Solda em Fio Sn60/Pb40 0.8mm (Carretel 500g)', 10, 15000, 1, 1, 1, '2026-08-20 09:00:00'),
    (30, 'Álcool Isopropílico 99.8% 1 Litro', 10, 4500, 1, 1, 1, '2026-08-20 09:00:00'),
    (31, 'Fita Kapton Térmica 10mm x 33m', 10, 3000, 1, 1, 1, '2026-08-20 09:00:00'),
    (32, 'Fita Dupla Face Fixação de Telas (3mm x 50m)', 10, 3500, 1, 1, 1, '2026-08-20 09:00:00'),
    (33, 'Fusível de Louça 5A 250V (Pacote c/ 10)', 14, 1800, 1, 1, 1, '2026-08-20 09:00:00'),
    (34, 'Capacitor Eletrolítico 1000uF x 25V', 14, 500, 1, 1, 1, '2026-08-20 09:00:00'),
    (35, 'Display Frontal Completo Samsung Galaxy S23', 12, 33000, 1, 1, 1, '2026-08-20 09:00:00');

INSERT INTO marca (id, nome_marca, id_funcionario, id_funcionario_cargo, status, data_cadastro) VALUES
    (1, 'Samsung', 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 'Apple', 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 'Xiaomi', 2, 2, 1, '2026-08-20 09:00:00'),
    (4, 'Motorola', 2, 2, 1, '2026-08-20 09:00:00'),
    (5, 'Lenovo', 1, 1, 1, '2026-08-20 09:00:00'),
    (6, 'Acer', 2, 2, 1, '2026-08-20 09:00:00');

INSERT INTO modelo (id, nome_modelo, id_marca, id_funcionario, id_funcionario_cargo, status, data_cadastro) VALUES
    (1, 'Galaxy S23', 1, 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 'iPhone 13', 2, 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 'Redmi Note 12', 3, 2, 2, 1, '2026-08-20 09:00:00'),
    (4, 'Moto G84', 4, 2, 2, 1, '2026-08-20 09:00:00'),
    (5, 'Galaxy A54', 1, 1, 1, 1, '2026-08-20 09:00:00'),
    (6, 'iPhone 15', 2, 1, 1, 1, '2026-08-20 09:00:00'),
    (7, 'IdeaPad 3', 5, 1, 1, 1, '2026-08-20 09:00:00'),
    (8, 'Smart TV Samsung 50"', 1, 1, 1, 1, '2026-08-20 09:00:00');

INSERT INTO tipo (id, nome_tipo, id_funcionario, id_funcionario_cargo, status, data_cadastro) VALUES
    (1, 'Smartphone', 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 'Notebook', 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 'Tablet', 2, 2, 1, '2026-08-20 09:00:00'),
    (4, 'Smartwatch', 2, 2, 1, '2026-08-20 09:00:00'),
    (5, 'Computador', 1, 1, 1, '2026-08-20 09:00:00'),
    (6, 'Smart TV', 1, 1, 1, '2026-08-20 09:00:00');

INSERT INTO equipamento (
    id, id_tipo, id_marca, id_modelo, id_cliente, numero_serie, imei, id_funcionario,
    id_funcionario_cargo, status, data_cadastro
) VALUES
    (1, 1, 1, 1, 1, 'SN-S23-001', '111111111111111', 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 1, 2, 2, 2, 'SN-IP13-002', '222222222222222', 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 1, 3, 3, 3, 'SN-RN12-003', '333333333333333', 2, 2, 1, '2026-08-20 09:00:00'),
    (4, 1, 4, 4, 1, 'SN-MG84-004', '444444444444444', 2, 2, 1, '2026-08-20 09:00:00'),
    (5, 1, 1, 5, 2, 'SN-A54-005', '555555555555555', 1, 1, 1, '2026-08-20 09:00:00'),
    (6, 2, 5, 7, 3, 'SN-IDEAPAD-006', NULL, 1, 1, 1, '2026-08-20 09:00:00'),
    (7, 6, 1, 8, 1, 'SN-TV50-007', NULL, 1, 1, 1, '2026-08-20 09:00:00');

INSERT INTO situacao (id, nome_situacao, status) VALUES
    (1, 'Aberto', 1),
    (2, 'Em Diagnóstico', 1),
    (3, 'Orçamento Aprovado', 1),
    (4, 'Em Reparo', 1),
    (5, 'Pronto', 1),
    (6, 'Entregue', 1),
    (7, 'Cancelado', 1);

INSERT INTO forma_pagamento (id, nome_forma_pagamento, id_funcionario, id_funcionario_cargo, status, data_cadastro) VALUES
    (1, 'Dinheiro', 1, 1, 1, '2026-08-20 09:00:00'),
    (2, 'Cartão de crédito', 1, 1, 1, '2026-08-20 09:00:00'),
    (3, 'Cartão de débito', 2, 2, 1, '2026-08-20 09:00:00'),
    (4, 'PIX', 2, 2, 1, '2026-08-20 09:00:00'),
    (5, 'Transferência bancária', 1, 1, 1, '2026-08-20 09:00:00');

-- Lotes de abertura de exemplo. Todo saldo começa com uma entrada registrada.
INSERT INTO entrada_peca (
    id, id_peca, quantidade, preco_de_compra, preco_sugerido_venda, id_funcionario,
    id_funcionario_cargo, status, data_cadastro
) VALUES
    (5, 1, 16, 15600, 26000, 1, 1, 1, '2026-08-25 09:00:00'),
    (6, 2, 20, 12600, 21000, 1, 1, 1, '2026-08-25 09:00:00'),
    (7, 3, 12, 10200, 17000, 1, 1, 1, '2026-08-25 09:00:00'),
    (8, 4, 8, 19200, 32000, 1, 1, 1, '2026-08-25 09:00:00'),
    (9, 5, 25, 3600, 6000, 1, 1, 1, '2026-08-25 09:00:00'),
    (10, 6, 6, 20400, 34000, 1, 1, 1, '2026-08-25 09:00:00'),
    (11, 7, 30, 1500, 2500, 1, 1, 1, '2026-08-25 09:00:00'),
    (12, 8, 10, 5700, 9500, 1, 1, 1, '2026-08-25 09:00:00'),
    (13, 9, 50, 900, 1500, 1, 1, 1, '2026-08-25 09:00:00'),
    (14, 10, 5, 28800, 48000, 1, 1, 1, '2026-08-25 09:00:00'),
    (15, 11, 3, 21000, 35000, 1, 1, 1, '2026-08-25 09:00:00'),
    (16, 12, 6, 18600, 31000, 1, 1, 1, '2026-08-25 09:00:00'),
    (17, 13, 5, 16800, 28000, 1, 1, 1, '2026-08-25 09:00:00'),
    (18, 14, 8, 9600, 16000, 1, 1, 1, '2026-08-25 09:00:00'),
    (19, 15, 6, 7800, 13000, 1, 1, 1, '2026-08-25 09:00:00'),
    (20, 16, 6, 7200, 12000, 1, 1, 1, '2026-08-25 09:00:00'),
    (21, 17, 100, 1200, 2000, 1, 1, 1, '2026-08-25 09:00:00'),
    (22, 18, 100, 900, 1500, 1, 1, 1, '2026-08-25 09:00:00'),
    (23, 19, 10, 3300, 5500, 1, 1, 1, '2026-08-25 09:00:00'),
    (24, 20, 4, 6600, 11000, 1, 1, 1, '2026-08-25 09:00:00'),
    (25, 21, 3, 8400, 14000, 1, 1, 1, '2026-08-25 09:00:00'),
    (26, 22, 40, 1500, 2500, 1, 1, 1, '2026-08-25 09:00:00'),
    (27, 23, 5, 13800, 23000, 1, 1, 1, '2026-08-25 09:00:00'),
    (28, 24, 5, 11700, 19500, 1, 1, 1, '2026-08-25 09:00:00'),
    (29, 25, 2, 18600, 31000, 1, 1, 1, '2026-08-25 09:00:00'),
    (30, 26, 2, 25200, 42000, 1, 1, 1, '2026-08-25 09:00:00'),
    (31, 27, 8, 3900, 6500, 1, 1, 1, '2026-08-25 09:00:00'),
    (32, 28, 15, 1200, 2000, 1, 1, 1, '2026-08-25 09:00:00'),
    (33, 29, 2, 9000, 15000, 1, 1, 1, '2026-08-25 09:00:00'),
    (34, 30, 12, 2700, 4500, 1, 1, 1, '2026-08-25 09:00:00'),
    (35, 31, 15, 1800, 3000, 1, 1, 1, '2026-08-25 09:00:00'),
    (36, 32, 10, 2100, 3500, 1, 1, 1, '2026-08-25 09:00:00'),
    (37, 33, 20, 1080, 1800, 1, 1, 1, '2026-08-25 09:00:00'),
    (38, 34, 150, 300, 500, 1, 1, 1, '2026-08-25 09:00:00'),
    (39, 35, 6, 19800, 33000, 1, 1, 1, '2026-08-25 09:00:00');

INSERT INTO ordem (
    id, id_equipamento, defeito_relatado, defeito_constatado, data_abertura, id_funcionario_abertura,
    id_funcionario_cargo_abertura, id_tecnico, id_tecnico_cargo
) VALUES
    (1, 1, 'Tela quebrada após queda.', 'Display frontal danificado, toque não responde.', '2026-09-01 09:30:00', 2, 2, 5, 3),
    (2, 6, 'Notebook muito lento para ligar.', 'Lentidão provocada por HD mecânico antigo.', '2026-09-10 10:15:00', 3, 2, 6, 3),
    (3, 7, 'TV com som, mas imagem não aparece.', 'Barra de LED queimada.', '2026-09-15 11:00:00', 2, 2, 5, 3),
    (4, 5, 'Celular para de carregar ao mexer no cabo.', 'Conector de carga com mau contato.', '2026-09-20 14:20:00', 3, 2, 6, 3);

INSERT INTO ordem_situacao (id_ordem, id_nova_situacao, id_tecnico, id_tecnico_cargo, data_situacao) VALUES
    (1, 2, 5, 3, '2026-09-01 10:00:00'),
    (1, 3, 5, 3, '2026-09-01 11:30:00'),
    (1, 4, 5, 3, '2026-09-01 14:00:00'),
    (2, 2, 6, 3, '2026-09-10 10:30:00'),
    (2, 3, 6, 3, '2026-09-10 10:45:00'),
    (2, 4, 6, 3, '2026-09-10 11:00:00'),
    (3, 2, 5, 3, '2026-09-15 14:00:00'),
    (3, 3, 5, 3, '2026-09-15 15:00:00'),
    (3, 4, 5, 3, '2026-09-15 15:30:00'),
    (4, 2, 6, 3, '2026-09-20 14:30:00'),
    (4, 3, 6, 3, '2026-09-20 15:00:00'),
    (4, 4, 6, 3, '2026-09-20 16:00:00');

INSERT INTO ordem_servico (id_ordem, id_servico, quantidade_servico, valor_unitario, data_execucao) VALUES
    (1, 6, 1, 15000, '2026-09-01 15:30:00'),
    (2, 3, 1, 8000, '2026-09-10 13:00:00'),
    (2, 1, 1, 12000, '2026-09-10 14:30:00'),
    (3, 11, 1, 35000, '2026-09-15 16:30:00'),
    (4, 9, 1, 11000, '2026-09-20 17:30:00');

INSERT INTO ordem_peca (id_ordem, id_peca, quantidade, valor_unitario, id_tecnico, id_tecnico_cargo, data_saida) VALUES
    (1, 35, 1, 33000, 5, 3, '2026-09-01 15:00:00'),
    (2, 1, 1, 26000, 6, 3, '2026-09-10 12:00:00'),
    (3, 23, 1, 23000, 5, 3, '2026-09-15 16:00:00'),
    (4, 17, 1, 2000, 6, 3, '2026-09-20 17:00:00');

-- A forma escolhida é gravada no pagamento quando a ordem é entregue.
UPDATE ordem SET id_forma_pagamento = 2 WHERE id = 1;

INSERT INTO ordem_situacao (id_ordem, id_nova_situacao, id_tecnico, id_tecnico_cargo, data_situacao) VALUES
    (1, 5, 5, 3, '2026-09-02 15:30:00'),
    (1, 6, 5, 3, '2026-09-02 16:00:00'),
    (2, 5, 6, 3, '2026-09-11 14:30:00');

INSERT INTO entrada_peca (
    id, id_peca, quantidade, preco_de_compra, preco_sugerido_venda, id_funcionario,
    id_funcionario_cargo, status, data_cadastro
) VALUES
    (1, 15, 10, 6000, 13000, 1, 1, 1, '2026-10-17 10:00:00'),
    (2, 11, 5, 18000, 35000, 1, 1, 1, '2026-10-17 10:00:00'),
    (3, 17, 50, 250, 2000, 1, 1, 1, '2026-10-17 10:00:00'),
    (4, 29, 2, 8500, 15000, 1, 1, 1, '2026-10-17 10:00:00');

INSERT INTO saida_peca (id, id_peca, quantidade, motivo, preco_de_compra, id_tecnico, id_tecnico_cargo, data_saida) VALUES
    (1, 22, 2, 'defeito', 500, 4, 3, '2026-10-17 15:00:00'),
    (2, 34, 5, 'avaria', 80, 5, 3, '2026-10-17 15:30:00');
