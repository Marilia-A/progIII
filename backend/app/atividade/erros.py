class ErroDeAtividade(Exception):
    pass

class AtividadeNaoEncontrada(ErroDeAtividade):
    pass

class TituloJaCadastrado(ErroDeAtividade):
    pass

class CampoNaoEditavel(ErroDeAtividade):
    pass

class AtividadeConcluida(ErroDeAtividade):
    pass