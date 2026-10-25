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

  static const _semApi = 'Não consegui falar com a API. O uvicorn está rodando?';

  Future<List<Atividade>> listar() async {
    try {
      return await repositorio.listar(sessao.token!);
    } on RecusaDaApi catch (e) {
      throw ErroDeAtividades(e.mensagem);
    } on Exception {
      throw ErroDeAtividades(_semApi);
    }
  }

  Future<Atividade> buscar(int id) async {
    try {
      return await repositorio.buscar(sessao.token!, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeAtividades(e.mensagem);
    } on Exception {
      throw ErroDeAtividades(_semApi);
    }
  }

  Future<Atividade> criar(
    String titulo,
    String? descricao,
    String categoria,
    DateTime? dataPrevista,
  ) async {
    try {
      return await repositorio.criar(
        sessao.token!,
        titulo,
        descricao,
        categoria,
        dataPrevista,
      );
    } on RecusaDaApi catch (e) {
      throw ErroDeAtividades(e.mensagem);
    } on Exception {
      throw ErroDeAtividades(_semApi);
    }
  }

  Future<Atividade> atualizar(
    int id,
    String titulo,
    String? descricao,
    String categoria,
    DateTime? dataPrevista,
  ) async {
    try {
      return await repositorio.atualizar(
        sessao.token!,
        id,
        titulo,
        descricao,
        categoria,
        dataPrevista,
      );
    } on RecusaDaApi catch (e) {
      throw ErroDeAtividades(e.mensagem);
    } on Exception {
      throw ErroDeAtividades(_semApi);
    }
  }

  Future<void> excluir(int id) async {
    try {
      await repositorio.excluir(sessao.token!, id);
    } on RecusaDaApi catch (e) {
      throw ErroDeAtividades(e.mensagem);
    } on Exception {
      throw ErroDeAtividades(_semApi);
    }
  }
}