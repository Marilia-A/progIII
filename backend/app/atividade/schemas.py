from datetime import date
from pydantic import BaseModel, ConfigDict, field_validator
from .models import CategoriaAtividade


def _titulo_legivel(titulo):
    if len(titulo.strip()) < 2:
        raise ValueError("o titulo precisa ter pelo menos 2 caracteres")
    if len(titulo.strip()) > 120:
        raise ValueError("o titulo pode ter no maximo 120 caracteres")
    return titulo.strip()


def _descricao_curta(descricao):
    if len(descricao) > 500:
        raise ValueError("a descricao pode ter no maximo 500 caracteres")
    return descricao


class AtividadeCriar(BaseModel):
    titulo: str
    descricao: str | None = None
    categoria: CategoriaAtividade
    data_prevista: date | None = None

    @field_validator("titulo")
    @classmethod
    def titulo_legivel(cls, v):
        return _titulo_legivel(v)

    @field_validator("descricao")
    @classmethod
    def descricao_curta(cls, v):
        return v if v is None else _descricao_curta(v)


class AtividadePublico(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    titulo: str
    descricao: str | None
    categoria: CategoriaAtividade
    concluida: bool
    data_prevista: date | None
    dono_id: int | None


class AtividadeAtualizar(BaseModel):
    titulo: str | None = None
    descricao: str | None = None
    categoria: CategoriaAtividade | None = None
    concluida: bool | None = None
    data_prevista: date | None = None

    @field_validator("titulo")
    @classmethod
    def titulo_legivel(cls, v):
        return v if v is None else _titulo_legivel(v)

    @field_validator("descricao")
    @classmethod
    def descricao_curta(cls, v):
        return v if v is None else _descricao_curta(v)