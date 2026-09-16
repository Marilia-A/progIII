from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..seguranca import get_current_user
from . import service
from .schemas import AtividadeAtualizar, AtividadeCriar, AtividadePublico

# A porta trancada: uma linha, e todas as rotas de atividades passam a exigir um token valido. Sem ele, o FastAPI responde 401 antes de a rota rodar.
router = APIRouter(
    prefix="/atividades",
    tags=["Atividades"],
    dependencies=[Depends(get_current_user)],
)

@router.get("/", response_model=list[AtividadePublico])
def listar(db: Session = Depends(get_db)):
    return service.listar(db)

@router.post("/", response_model=AtividadePublico, status_code=201)
def criar(dados: AtividadeCriar, db: Session = Depends(get_db)):
    return service.criar(db, dados.model_dump())

@router.get("/{atividade_id}", response_model=AtividadePublico)
def buscar(atividade_id: int, db: Session = Depends(get_db)):
    return service.buscar(db, atividade_id)

@router.patch("/{atividade_id}", response_model=AtividadePublico)
def atualizar(atividade_id: int, dados: AtividadeAtualizar, db: Session = Depends(get_db)):
    return service.atualizar(db, atividade_id, dados.model_dump(exclude_unset=True))

@router.delete("/{atividade_id}", status_code=204)
def apagar(atividade_id: int, db: Session = Depends(get_db)):
    service.apagar(db, atividade_id)