from sqlalchemy.orm import Session
from .models import Atividade


def listar(db: Session, dono_id: int, titulo=None, categoria=None, concluida=None):
    consulta = db.query(Atividade).filter(Atividade.dono_id == dono_id)
    if titulo:
        consulta = consulta.filter(Atividade.titulo.ilike(f"%{titulo}%"))
    if categoria is not None:
        consulta = consulta.filter(Atividade.categoria == categoria)
    if concluida is not None:
        consulta = consulta.filter(Atividade.concluida == concluida)
    return consulta.order_by(Atividade.titulo).all()


def buscar(db: Session, atividade_id: int):
    return db.query(Atividade).filter(Atividade.id == atividade_id).first()


def buscar_por_titulo(db: Session, dono_id: int, titulo: str):
    return db.query(Atividade).filter(Atividade.dono_id == dono_id, Atividade.titulo == titulo).first()


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