import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class ErroDeLogin implements Exception {
  ErroDeLogin(this.mensagem);
  final String mensagem;
}

class SessaoService {
  SessaoService(this.repositorio);

  final UsuarioRepository repositorio;
  String? token;

  Future<void> entrar(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) {
      throw ErroDeLogin('Preencha o e-mail e a senha');
    }
    String? recebido;
    try {
      recebido = await repositorio.entrar(email, senha);
    } catch (e) {
      throw ErroDeLogin('Não consegui falar com a API. O uvicorn está rodando?');
    }
    if (recebido == null) {
      throw ErroDeLogin('E-mail ou senha incorretos');
    }
    token = recebido;
  }

  Future<Usuario> usuarioLogado() {
    return repositorio.quemSouEu(token!);
  }

  void sair() {
    token = null;
  }
}