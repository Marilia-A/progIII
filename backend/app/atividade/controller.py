from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from . import service
from .schemas import AtividadeAtualizar, AtividadeCriar, AtividadePublico

router = APIRouter(prefix="/atividades", tags=["Atividades"])

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