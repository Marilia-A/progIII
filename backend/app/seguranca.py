"""O que a aplicacao inteira usa para reconhecer quem esta' falando com ela."""

import os
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt
from dotenv import load_dotenv
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from .database import get_db
from .usuarios import repository as usuarios_repository
from .usuarios.erros import CredenciaisInvalidas

load_dotenv()

SECRET_KEY = os.environ["SECRET_KEY"]
ALGORITMO = "HS256"
TOKEN_DURA_MINUTOS = 60

esquema_oauth = OAuth2PasswordBearer(tokenUrl="/usuarios/login")


def gerar_hash(senha: str) -> str:
    return bcrypt.hashpw(senha.encode(), bcrypt.gensalt()).decode()


def conferir_senha(senha: str, senha_hash: str) -> bool:
    return bcrypt.checkpw(senha.encode(), senha_hash.encode())

def criar_token(usuario_id: int) -> str:
    """O cracha': quem e' (sub) e ate' quando vale (exp), assinado."""
    expira = datetime.now(timezone.utc) + timedelta(minutes=TOKEN_DURA_MINUTOS)
    return jwt.encode(
        {"sub": str(usuario_id), "exp": expira}, SECRET_KEY, algorithm=ALGORITMO
    )

def get_current_user(
    token: str = Depends(esquema_oauth),
    db: Session = Depends(get_db),
):
    """O porteiro. Le o cracha', confere a assinatura e busca quem e'."""
    try:
        dados = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITMO])
    except jwt.PyJWTError:
        raise CredenciaisInvalidas("Token invalido ou vencido")
    usuario = usuarios_repository.buscar(db, int(dados["sub"]))
    if usuario is None:
        raise CredenciaisInvalidas("O usuario deste token nao existe mais")
    return usuario