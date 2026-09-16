"""As regras de conta e de login, e mais nada."""
from .. import seguranca
from . import repository
from .erros import CredenciaisInvalidas, EmailJaCadastrado


def cadastrar(db, dados):
    # RN04: um e-mail, uma conta.
    if repository.buscar_por_email(db, dados["email"]):
        raise EmailJaCadastrado(f"Ja existe uma conta com o e-mail {dados['email']}")
    senha = dados.pop("senha")
    return repository.criar(db, {**dados, "senha_hash": seguranca.gerar_hash(senha)})


def autenticar(db, email, senha):
    usuario = repository.buscar_por_email(db, email)
    if usuario is None or not seguranca.conferir_senha(senha, usuario.senha_hash):
        raise CredenciaisInvalidas("E-mail ou senha incorretos")
    return usuario