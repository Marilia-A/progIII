from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from .atividade import controller as atividade_controller
from .atividade.erros import ErroDeAtividade, AtividadeNaoEncontrada
from .usuarios import controller as usuarios_controller
from .usuarios.erros import CredenciaisInvalidas, ErroDeUsuario

# Tabelas criadas/alteradas pelo Alembic: poetry run alembic upgrade head

app = FastAPI(title="Checklist de Robotica", version="0.5.0")

app.include_router(usuarios_controller.router)
app.include_router(atividade_controller.router)


@app.exception_handler(ErroDeAtividade)
def traduzir_recusa(request: Request, erro: ErroDeAtividade):
    codigo = 404 if isinstance(erro, AtividadeNaoEncontrada) else 409
    return JSONResponse(status_code=codigo, content={"detail": str(erro)})


@app.exception_handler(ErroDeUsuario)
def traduzir_recusa_de_usuario(request: Request, erro: ErroDeUsuario):
    if isinstance(erro, CredenciaisInvalidas):
        return JSONResponse(
            status_code=401,
            content={"detail": str(erro)},
            headers={"WWW-Authenticate": "Bearer"},
        )
    return JSONResponse(status_code=409, content={"detail": str(erro)})