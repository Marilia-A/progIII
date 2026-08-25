import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/atividade.dart';

class ApiService {
  // Emulador Android usa 10.0.2.2; no Chrome/Windows use 127.0.0.1
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Atividade>> listar({String? busca, String? categoria, bool? concluida}) async {
    final params = <String, String>{};
    if (busca != null) params['busca'] = busca;
    if (categoria != null) params['categoria'] = categoria;
    if (concluida != null) params['concluida'] = concluida.toString();

    final uri = Uri.parse('$baseUrl/atividades/').replace(queryParameters: params);
    final resposta = await http.get(uri);

    if (resposta.statusCode == 200) {
      final List dados = jsonDecode(resposta.body);
      return dados.map((json) => Atividade.fromJson(json)).toList();
    }
    throw Exception('Erro ao listar atividades');
  }

  Future<Atividade> criar(Atividade atividade) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/atividades/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(atividade.toJson()),
    );

    if (resposta.statusCode == 201) {
      return Atividade.fromJson(jsonDecode(resposta.body));
    }
    throw Exception('Erro ao criar atividade');
  }

  Future<Atividade> atualizar(int id, Map<String, dynamic> campos) async {
    final resposta = await http.patch(
      Uri.parse('$baseUrl/atividades/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(campos),
    );

    if (resposta.statusCode == 200) {
      return Atividade.fromJson(jsonDecode(resposta.body));
    }
    throw Exception('Erro ao atualizar atividade');
  }

  Future<void> apagar(int id) async {
    final resposta = await http.delete(Uri.parse('$baseUrl/atividades/$id'));
    if (resposta.statusCode != 204) {
      throw Exception('Erro ao apagar atividade');
    }
  }
}