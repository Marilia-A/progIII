from fastapi import APIRouter, HTTPException
from .schemas import AtividadeCriar, AtividadePublico, AtividadeAtualizar

router = APIRouter(prefix="/atividades", tags=["Atividades"])

atividades: list[dict] = []


@router.get("/", response_model=list[AtividadePublico])
def listar(busca: str | None = None, categoria: str | None = None, concluida: bool | None = None):
    resultado = atividades
    if busca:
        resultado = [a for a in resultado if busca.lower() in a["titulo"].lower()]
    if categoria:
        resultado = [a for a in resultado if a["categoria"] == categoria]
    if concluida is not None:
        resultado = [a for a in resultado if a["concluida"] == concluida]
    return resultado


@router.post("/", response_model=AtividadePublico, status_code=201)
def criar(dados: AtividadeCriar):
    nova = {"id": len(atividades) + 1, **dados.model_dump()}
    atividades.append(nova)
    return nova


@router.get("/{atividade_id}", response_model=AtividadePublico)
def buscar(atividade_id: int):
    for a in atividades:
        if a["id"] == atividade_id:
            return a
    raise HTTPException(status_code=404, detail="Atividade nao encontrada")


@router.patch("/{atividade_id}", response_model=AtividadePublico)
def atualizar(atividade_id: int, dados: AtividadeAtualizar):
    for a in atividades:
        if a["id"] == atividade_id:
            a.update(dados.model_dump(exclude_unset=True))
            return a
    raise HTTPException(status_code=404, detail="Atividade nao encontrada")


@router.delete("/{atividade_id}", status_code=204)
def apagar(atividade_id: int):
    for a in atividades:
        if a["id"] == atividade_id:
            atividades.remove(a)
            return
    raise HTTPException(status_code=404, detail="Atividade nao encontrada")