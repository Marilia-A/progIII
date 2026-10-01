import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

const enderecoDaApi = 'http://127.0.0.1:8000';

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

  Future<Usuario> quemSouEu(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/usuarios/eu'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return Usuario.fromJson(jsonDecode(resposta.body));
  }
}