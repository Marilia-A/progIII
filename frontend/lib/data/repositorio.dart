import '../models/models.dart';

/// Repositório em memória com DADOS DE EXEMPLO FIXOS.
///
/// Não há backend, banco nem autenticação real. Os métodos simulam
/// latência de rede com Future.delayed para que as telas possam exibir
/// os estados de CARREGANDO / ERRO / VAZIO / SUCESSO.
class Repositorio {
  Repositorio._();
  static final Repositorio instance = Repositorio._();

  /// Interruptor para forçar o estado de ERRO nas telas (fins de protótipo).
  bool simularErro = false;

  /// Usuários de exemplo aceitos na tela de Login.
  final List<Usuario> _usuarios = [
    Usuario(
      nome: "Ana Aluna",
      email: "aluno@escola.br",
      senha: "123456",
      papel: PapelUsuario.aluno,
    ),
    Usuario(
      nome: "Prof. Bruno",
      email: "professor@escola.br",
      senha: "123456",
      papel: PapelUsuario.professor,
    ),
    Usuario(
      nome: "Admin",
      email: "admin@escola.br",
      senha: "123456",
      papel: PapelUsuario.admin,
    ),
  ];

  Usuario? usuarioLogado;

  final List<Roteiro> _roteiros = [
    Roteiro(
      id: "1",
      conteudo: Conteudo(
        passoAPasso: [
          Passo(descricao: "Monte o chassi do robô encaixando as duas placas."),
          Passo(descricao: "Conecte os dois motores nas rodas traseiras."),
          Passo(descricao: "Ligue a placa controladora e teste o LED."),
        ],
        imagens: [
          Imagem(legenda: "Chassi montado"),
          Imagem(legenda: "Motores conectados"),
        ],
      ),
      concluido: true,
    ),
    Roteiro(
      id: "2",
      conteudo: Conteudo(
        passoAPasso: [
          Passo(descricao: "Instale o sensor ultrassônico na frente do robô."),
          Passo(descricao: "Programe a leitura de distância em centímetros."),
        ],
        imagens: [
          Imagem(legenda: "Sensor posicionado"),
        ],
      ),
    ),
    Roteiro(
      id: "3",
      conteudo: Conteudo(
        passoAPasso: [
          Passo(descricao: "Conecte o seguidor de linha na parte inferior."),
        ],
        imagens: [],
      ),
    ),
  ];

  int _proximoId = 4;

  // -- Autenticação simulada --------------------------------------------------

  Future<Usuario> login(String email, String senha) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (simularErro) {
      throw Exception("Não foi possível conectar ao servidor.");
    }
    final encontrado = _usuarios.where(
      (u) => u.email == email.trim() && u.senha == senha,
    );
    if (encontrado.isEmpty) {
      throw Exception("E-mail ou senha inválidos.");
    }
    usuarioLogado = encontrado.first;
    return usuarioLogado!;
  }

  Future<Usuario> cadastrar(
      String nome, String email, String senha) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (simularErro) {
      throw Exception("Não foi possível concluir o cadastro.");
    }
    if (_usuarios.any((u) => u.email == email.trim())) {
      throw Exception("Este e-mail já está cadastrado.");
    }
    final novo = Usuario(
      nome: nome.trim(),
      email: email.trim(),
      senha: senha,
      papel: PapelUsuario.aluno,
    );
    _usuarios.add(novo);
    usuarioLogado = novo;
    return novo;
  }

  void logout() => usuarioLogado = null;

  // -- Roteiros ---------------------------------------------------------------

  Future<List<Roteiro>> listarRoteiros({String busca = ""}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (simularErro) {
      throw Exception("Falha ao carregar os roteiros.");
    }
    final termo = busca.trim().toLowerCase();
    if (termo.isEmpty) return List.unmodifiable(_roteiros);
    return _roteiros
        .where((r) => r.conteudo.passoAPasso
            .any((p) => p.descricao.toLowerCase().contains(termo)))
        .toList();
  }

  Roteiro? porId(String id) {
    for (final r in _roteiros) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<Roteiro> criar(Conteudo conteudo) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (simularErro) {
      throw Exception("Não foi possível salvar o roteiro.");
    }
    final novo = Roteiro(id: "${_proximoId++}", conteudo: conteudo);
    _roteiros.add(novo);
    return novo;
  }

  Future<Roteiro> editar(String id, Conteudo conteudo) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (simularErro) {
      throw Exception("Não foi possível salvar as alterações.");
    }
    final r = porId(id);
    if (r == null) throw Exception("Roteiro não encontrado.");
    r.conteudo = conteudo;
    return r;
  }

  Future<void> excluir(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (simularErro) {
      throw Exception("Não foi possível excluir o roteiro.");
    }
    _roteiros.removeWhere((r) => r.id == id);
  }

  Future<void> concluir(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    porId(id)?.concluido = true;
  }
}
