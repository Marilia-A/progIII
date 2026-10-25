import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/atividade.dart';
import 'usuario_repository.dart';

class AtividadeRepository {
  AtividadeRepository({http.Client? cliente}) : cliente = cliente ?? http.Client();

  final http.Client cliente;

  Map<String, String> _cabecalho(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<List<Atividade>> listar(String token) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/atividades/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta));
    }
    final itens = jsonDecode(utf8.decode(resposta.bodyBytes));
    return [for (final item in itens) Atividade.fromJson(item)];
  }

  Future<Atividade> buscar(String token, int id) async {
    final resposta = await cliente.get(
      Uri.parse('$enderecoDaApi/atividades/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta));
    }
    return Atividade.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
  }

  Future<Atividade> criar(
    String token,
    String titulo,
    String? descricao,
    String categoria,
    DateTime? dataPrevista,
  ) async {
    final resposta = await cliente.post(
      Uri.parse('$enderecoDaApi/atividades/'),
      headers: _cabecalho(token),
      body: jsonEncode(_corpo(titulo, descricao, categoria, dataPrevista)),
    );
    if (resposta.statusCode != 201) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta));
    }
    return Atividade.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
  }

  Future<Atividade> atualizar(
    String token,
    int id,
    String titulo,
    String? descricao,
    String categoria,
    DateTime? dataPrevista,
  ) async {
    final resposta = await cliente.patch(
      Uri.parse('$enderecoDaApi/atividades/$id'),
      headers: _cabecalho(token),
      body: jsonEncode(_corpo(titulo, descricao, categoria, dataPrevista)),
    );
    if (resposta.statusCode != 200) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta));
    }
    return Atividade.fromJson(jsonDecode(utf8.decode(resposta.bodyBytes)));
  }

  Future<void> excluir(String token, int id) async {
    final resposta = await cliente.delete(
      Uri.parse('$enderecoDaApi/atividades/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode != 204) {
      throw RecusaDaApi(resposta.statusCode, _frase(resposta));
    }
  }

  // concluida nunca vai: a RN02 não deixa editar pelo PATCH
  Map<String, dynamic> _corpo(
    String titulo,
    String? descricao,
    String categoria,
    DateTime? dataPrevista,
  ) {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'data_prevista': dataPrevista?.toIso8601String().substring(0, 10),
    };
  }

  String _frase(http.Response resposta) {
    final detalhe = jsonDecode(utf8.decode(resposta.bodyBytes))['detail'];
    if (detalhe is String) {
      return detalhe;
    }
    final primeiro = detalhe[0];
    final mensagem = '${primeiro['msg']}'.replaceFirst('Value error, ', '');
    return '${primeiro['loc'].last}: $mensagem';
  }
}