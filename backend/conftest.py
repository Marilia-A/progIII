"""O que todo teste usa. O pytest lê este arquivo sozinho, antes dos testes."""
import os

# ANTES de importar o app: o database.py lê o endereço do banco na hora do
# import, e o .env não troca uma variável que já existe.
os.environ["DATABASE_URL"] = "sqlite:///./teste.db"
os.environ["SECRET_KEY"] = "uma-chave-so-para-os-testes-com-mais-de-32-letras"

import pytest
from fastapi.testclient import TestClient

from app.database import Base, engine
from app.main import app


@pytest.fixture
def cliente():
    Base.metadata.create_all(engine)    # cria as tabelas, vazias
    yield TestClient(app)               # o teste roda aqui
    Base.metadata.drop_all(engine)      # apaga tudo para o próximo teste