from datetime import date
from pydantic import BaseModel, ConfigDict, Field
from .models import CategoriaAtividade

class AtividadeCriar(BaseModel):
    titulo: str = Field(min_length=2)
    descricao: str | None = None
    categoria: CategoriaAtividade
    data_prevista: date | None = None
    aluno_id: int | None = None

class AtividadePublico(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    titulo: str
    descricao: str | None
    categoria: CategoriaAtividade
    concluida: bool
    data_prevista: date | None
    aluno_id: int | None

class AtividadeAtualizar(BaseModel):
    titulo: str | None = None
    descricao: str | None = None
    categoria: CategoriaAtividade | None = None
    concluida: bool | None = None
    data_prevista: date | None = None