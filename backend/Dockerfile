# A receita da API. Quem constrói a imagem é o serviço de nuvem (o Render):
# nada disto precisa de Docker na sua máquina.

# Comece de uma base pronta: um Python já instalado, na versão do pyproject.toml.
FROM python:3.13-slim

# A pasta de trabalho, dentro do contêiner.
WORKDIR /codigo

# Instale os pacotes do projeto, sem os de desenvolvimento (o pytest fica fora).
# O --no-root: o projeto não é um pacote para instalar, só o código da API.
COPY pyproject.toml poetry.lock* ./
RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --only main --no-root --no-interaction

# Copie o código. O .dockerignore diz o que não entra (o .env, os bancos, os testes).
COPY . .

# Ao ligar: crie ou atualize as tabelas e suba a API. O serviço de nuvem diz a
# porta na variável PORT; sem ela, a 8000.
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
