import enum
from sqlalchemy import Boolean, Column, Date, Enum as SqlEnum, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
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
    dono_id = Column(Integer, ForeignKey("usuarios.id", name="fk_atividades_dono"), nullable=True)
    dono = relationship("Usuario", back_populates="atividades")