import '../models/atividade.dart';
import '../repositories/atividade_repository.dart';
import '../repositories/usuario_repository.dart';
import 'sessao_service.dart';

class ErroDeAtividades implements Exception {
  ErroDeAtividades(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class AtividadeService {
  AtividadeService(this.repositorio, this.sessao);

  final AtividadeRepository repositorio;
  final SessaoService sessao;

  Future<List<Atividade>> listar() async {
    try {
      return await repositorio.listar(sessao.token!);
    } on RecusaDaApi catch (e) {
      throw ErroDeAtividades(e.mensagem);
    } on Exception {
      throw ErroDeAtividades('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }

  Future<Atividade> buscar(int id) async {
    try {
      return await repositorio.buscar(sessao.token!, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeAtividades(e.mensagem);
    } on Exception {
      throw ErroDeAtividades('Não consegui falar com a API. O uvicorn está rodando?');
    }
  }
}