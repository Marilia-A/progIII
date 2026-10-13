import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

const enderecoDaApi = 'http://127.0.0.1:8000';

class RecusaDaApi implements Exception {
  RecusaDaApi(this.status, this.mensagem);
  final int status;
  final String mensagem;
}

class UsuarioRepository {
  UsuarioRepository({http.Client? cliente}) : cliente = cliente ?? http.Client();

  final http.Client cliente;

  Future<String?> entrar(String email, String senha) async {
    final resposta = await cliente.post(
      Uri.parse('$enderecoDaApi/usuarios/login'),
      body: {'username': email, 'password': senha},
    );
    if (resposta.statusCode != 200) {
      return null;
    }
    final corpo = jsonDecode(resposta.body);
    return corpo['access_token'];
  }

  Future<Usuario> cadastrar(String nome, String email, String senha) async {
    final resposta = await cliente.post(
      Uri.parse('$enderecoDaApi/usuarios/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );
    if (resposta.statusCode != 201) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Usuario.fromJson(jsonDecode(resposta.body));
  }

  Future<Usuario> quemSouEu(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/usuarios/eu'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta.body));
    }
    return Usuario.fromJson(jsonDecode(resposta.body));
  }

  String _frase(String corpo) {
    final detalhe = jsonDecode(corpo)['detail'];
    if (detalhe is String) {
      return detalhe;
    }
    final primeiro = detalhe[0];
    return '${primeiro['loc'].last}: ${primeiro['msg']}';
  }
}