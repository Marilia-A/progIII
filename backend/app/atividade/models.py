import enum
from sqlalchemy import Boolean, Column, Date, Enum as SqlEnum, Integer, String
from ..database import Base

class CategoriaAtividade(str, enum.Enum):
    hardware = "hardware"
    programacao = "programacao"
    montagem = "montagem"

class Atividade(Base):
    __tablename__ = "atividades"
    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(120), nullable=False)
    descricao = Column(String(500), nullable=True)
    categoria = Column(SqlEnum(CategoriaAtividade), nullable=False)
    concluida = Column(Boolean, nullable=False, default=False)
    data_prevista = Column(Date, nullable=True)
    aluno_id = Column(Integer, nullable=True)