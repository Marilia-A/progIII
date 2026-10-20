import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/atividade.dart';
import 'usuario_repository.dart';

class AtividadeRepository {
  AtividadeRepository({http.Client? cliente}) : cliente = cliente ?? http.Client();

  final http.Client cliente;

  Future<List<Atividade>> listar(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/atividades/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, corpo['detail']);
    }
    return [for (final item in corpo) Atividade.fromJson(item)];
  }

  Future<Atividade> buscar(String token, int id) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/atividades/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, corpo['detail']);
    }
    return Atividade.fromJson(corpo);
  }
}