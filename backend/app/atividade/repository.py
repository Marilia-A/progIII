from sqlalchemy.orm import Session
from .models import Atividade

def listar(db: Session):
    return db.query(Atividade).all()

def buscar(db: Session, atividade_id: int):
    return db.query(Atividade).filter(Atividade.id == atividade_id).first()

def buscar_por_titulo(db: Session, titulo: str):
    return db.query(Atividade).filter(Atividade.titulo == titulo).first()

def criar(db: Session, dados: dict):
    atividade = Atividade(**dados)
    db.add(atividade)
    db.commit()
    db.refresh(atividade)
    return atividade

def atualizar(db: Session, atividade: Atividade, mudancas: dict):
    for campo, valor in mudancas.items():
        setattr(atividade, campo, valor)
    db.commit()
    db.refresh(atividade)
    return atividade

def apagar(db: Session, atividade: Atividade):
    db.delete(atividade)
    db.commit()