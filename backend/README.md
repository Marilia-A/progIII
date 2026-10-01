# Checklist de Robótica — API

API FastAPI do checklist de atividades de robótica educacional. Cada atividade tem **dono** (um usuário tem muitas atividades), cada aluno enxerga só as próprias, a listagem tem **busca e filtro**, e o `422` explica o erro em português. As tabelas são criadas e alteradas por **migrações Alembic**.

## Requisitos
- Python 3.13+ e Poetry
- PostgreSQL rodando, com um banco `checklist_robotica` criado

## Rodar do zero
Dentro de `backend/`:
```
poetry install
```
Crie `backend/.env`:
```
DATABASE_URL=postgresql+psycopg://USUARIO:SENHA@localhost:5432/checklist_robotica
SECRET_KEY=uma_chave_aleatoria_longa
```
```
poetry run alembic upgrade head
poetry run uvicorn app.main:app --reload
```
Abra http://127.0.0.1:8000/docs

## CORS
A API aceita pedidos de `localhost` e `127.0.0.1` em qualquer porta, para o app Flutter no navegador conseguir falar com ela.

## O que testar no /docs
1. `POST /usuarios/` cria a conta; **Authorize** com e-mail e senha
2. `POST /atividades/` → 201 com `dono_id` preenchido pelo token
3. `GET /atividades/?titulo=...&categoria=...&concluida=...` → busca e filtros
4. Título com 1 caractere → 422 com mensagem em português
5. Outro usuário: `GET /atividades/` → `[]`; `GET /atividades/1` → 404

## Estrutura
- `alembic/versions/` — histórico do banco (2 migrações)
- `app/atividade/` — models, schemas, repository, service, controller, erros
- `app/usuarios/` — cadastro, login JWT
- `app/seguranca.py` — hash e token
- `app/main.py` — monta a API, o CORS e os tradutores de erro