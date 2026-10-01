from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..seguranca import get_current_user
from ..usuarios.models import Usuario
from . import service
from .models import CategoriaAtividade
from .schemas import AtividadeAtualizar, AtividadeCriar, AtividadePublico

router = APIRouter(
    prefix="/atividades",
    tags=["Atividades"],
    dependencies=[Depends(get_current_user)],
)


@router.get("/", response_model=list[AtividadePublico])
def listar(
    titulo: str | None = None,
    categoria: CategoriaAtividade | None = None,
    concluida: bool | None = None,
    usuario: Usuario = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return service.listar(db, usuario, titulo, categoria, concluida)


@router.post("/", response_model=AtividadePublico, status_code=201)
def criar(dados: AtividadeCriar, usuario: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    return service.criar(db, usuario, dados.model_dump())


@router.get("/{atividade_id}", response_model=AtividadePublico)
def buscar(atividade_id: int, usuario: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    return service.buscar(db, usuario, atividade_id)


@router.patch("/{atividade_id}", response_model=AtividadePublico)
def atualizar(
    atividade_id: int,
    dados: AtividadeAtualizar,
    usuario: Usuario = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return service.atualizar(db, usuario, atividade_id, dados.model_dump(exclude_unset=True))


@router.delete("/{atividade_id}", status_code=204)
def apagar(atividade_id: int, usuario: Usuario = Depends(get_current_user), db: Session = Depends(get_db)):
    service.apagar(db, usuario, atividade_id)