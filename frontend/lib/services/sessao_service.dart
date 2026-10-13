import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/token_repository.dart';
import '../repositories/usuario_repository.dart';

class ErroDeLogin implements Exception {
  ErroDeLogin(this.mensagem);
  final String mensagem;
}

class ErroDeCadastro implements Exception {
  ErroDeCadastro(this.mensagem);
  final String mensagem;
}

class SessaoService extends ChangeNotifier {
  SessaoService(this.repositorio, {TokenRepository? tokens})
      : tokens = tokens ?? TokenRepository();

  final UsuarioRepository repositorio;
  final TokenRepository tokens;
  String? token;
  Usuario? usuario;

  bool get logado => token != null;

  Future<void> entrar(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) {
      throw ErroDeLogin('Preencha o e-mail e a senha');
    }
    String? recebido;
    Usuario? quem;
    try {
      recebido = await repositorio.entrar(email, senha);
      if (recebido != null) {
        quem = await repositorio.quemSouEu(recebido);
      }
    } catch (e) {
      throw ErroDeLogin('Não consegui falar com a API. O uvicorn está rodando?');
    }
    if (recebido == null) {
      throw ErroDeLogin('E-mail ou senha incorretos');
    }
    token = recebido;
    usuario = quem;
    await tokens.salvar(recebido);
    notifyListeners();
  }

  Future<void> cadastrar(String nome, String email, String senha) async {
    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      throw ErroDeCadastro('Preencha o nome, o e-mail e a senha');
    }
    try {
      await repositorio.cadastrar(nome, email, senha);
      await entrar(email, senha);
    } on RecusaDaApi catch (e) {
      if (e.status == 409) {
        throw ErroDeCadastro('Já existe uma conta com este e-mail');
      }
      throw ErroDeCadastro(e.mensagem);
    } on ErroDeLogin {
      throw ErroDeCadastro('Conta criada, mas não consegui entrar. Tente pelo login.');
    } catch (e) {
      throw ErroDeCadastro('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }

  Future<void> restaurar() async {
    final guardado = await tokens.ler();
    if (guardado == null) {
      return;
    }
    try {
      usuario = await repositorio.quemSouEu(guardado);
      token = guardado;
      notifyListeners();
    } on RecusaDaApi {
      await tokens.apagar();
    } catch (e) {
      // API fora do ar: o token fica guardado
    }
  }

  Future<void> sair() async {
    await tokens.apagar();
    token = null;
    usuario = null;
    notifyListeners();
  }
}