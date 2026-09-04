from . import repository
from .erros import (
    AtividadeConcluida,
    AtividadeNaoEncontrada,
    CampoNaoEditavel,
    TituloJaCadastrado,
)

RN02_PROIBIDO = "concluida"

def listar(db):
    return repository.listar(db)

def buscar(db, atividade_id):
    atividade = repository.buscar(db, atividade_id)
    if atividade is None:
        raise AtividadeNaoEncontrada(f"Atividade {atividade_id} nao encontrada")
    return atividade

def criar(db, dados):
    if repository.buscar_por_titulo(db, dados["titulo"]):
        raise TituloJaCadastrado(f"Ja existe atividade chamada {dados['titulo']}")
    return repository.criar(db, dados)

def atualizar(db, atividade_id, mudancas):
    atividade = buscar(db, atividade_id)
    novo_titulo = mudancas.get("titulo")
    if novo_titulo and novo_titulo != atividade.titulo:
        if repository.buscar_por_titulo(db, novo_titulo):
            raise TituloJaCadastrado(f"Ja existe atividade chamada {novo_titulo}")
    if RN02_PROIBIDO in mudancas:
        raise CampoNaoEditavel("concluida nao se edita pelo PATCH de cadastro")
    return repository.atualizar(db, atividade, mudancas)

def apagar(db, atividade_id):
    atividade = buscar(db, atividade_id)
    if atividade.concluida:
        raise AtividadeConcluida(f"Atividade {atividade_id} ja concluida, nao pode ser apagada")
    repository.apagar(db, atividade)