from datetime import date
from enum import Enum
from pydantic import BaseModel, Field


class CategoriaAtividade(str, Enum):
    hardware = "hardware"
    programacao = "programacao"
    montagem = "montagem"


class AtividadeCriar(BaseModel):
    titulo: str = Field(min_length=2)
    descricao: str | None = None
    categoria: CategoriaAtividade
    concluida: bool = False
    data_prevista: date | None = None


class AtividadePublico(BaseModel):
    id: int
    titulo: str
    descricao: str | None
    categoria: CategoriaAtividade
    concluida: bool
    data_prevista: date | None


class AtividadeAtualizar(BaseModel):
    titulo: str | None = None
    descricao: str | None = None
    categoria: CategoriaAtividade | None = None
    concluida: bool | None = None
    data_prevista: date | None = None