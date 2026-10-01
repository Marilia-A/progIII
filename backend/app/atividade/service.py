from . import repository
from .erros import (
    AtividadeConcluida,
    AtividadeNaoEncontrada,
    CampoNaoEditavel,
    TituloJaCadastrado,
)

RN02_PROIBIDO = "concluida"


def listar(db, usuario, titulo=None, categoria=None, concluida=None):
    return repository.listar(db, usuario.id, titulo, categoria, concluida)


def buscar(db, usuario, atividade_id):
    atividade = repository.buscar(db, atividade_id)
    # RN05: cada aluno so' enxerga as proprias atividades (404, nao 403)
    if atividade is None or atividade.dono_id != usuario.id:
        raise AtividadeNaoEncontrada(f"Atividade {atividade_id} nao esta na sua lista")
    return atividade


def criar(db, usuario, dados):
    if repository.buscar_por_titulo(db, usuario.id, dados["titulo"]):
        raise TituloJaCadastrado(f"Ja existe atividade chamada {dados['titulo']}")
    return repository.criar(db, {**dados, "dono_id": usuario.id})


def atualizar(db, usuario, atividade_id, mudancas):
    atividade = buscar(db, usuario, atividade_id)
    novo_titulo = mudancas.get("titulo")
    if novo_titulo and novo_titulo != atividade.titulo:
        if repository.buscar_por_titulo(db, usuario.id, novo_titulo):
            raise TituloJaCadastrado(f"Ja existe atividade chamada {novo_titulo}")
    if RN02_PROIBIDO in mudancas:
        raise CampoNaoEditavel("concluida nao se edita pelo PATCH de cadastro")
    return repository.atualizar(db, atividade, mudancas)


def apagar(db, usuario, atividade_id):
    atividade = buscar(db, usuario, atividade_id)
    if atividade.concluida:
        raise AtividadeConcluida(f"Atividade {atividade_id} ja concluida, nao pode ser apagada")
    repository.apagar(db, atividade)