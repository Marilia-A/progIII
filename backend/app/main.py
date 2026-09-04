from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from .database import Base, engine
from .atividade import controller as atividade_controller
from .atividade.erros import ErroDeAtividade, AtividadeNaoEncontrada

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Checklist de Robotica", version="0.3.0")
app.include_router(atividade_controller.router)

@app.exception_handler(ErroDeAtividade)
def traduzir_recusa(request: Request, erro: ErroDeAtividade):
    codigo = 404 if isinstance(erro, AtividadeNaoEncontrada) else 409
    return JSONResponse(status_code=codigo, content={"detail": str(erro)})