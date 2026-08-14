// Modelos de domínio do protótipo.
//
// Espelham a ENTIDADE PRINCIPAL descrita na especificação:
//   roteiro -> conteudo -> passo_a_passo (+ imagens)
// e os tipos de usuário (aluno, professor, admin).
//
// Nenhum campo além dos listados na especificação foi inventado.

/// Uma imagem que compõe o conteúdo.
/// Em produção seria uma URL vinda da API FastAPI; aqui é só uma legenda
/// de exemplo para representar o anexo visual.
class Imagem {
  Imagem({required this.legenda});

  String legenda;
}

/// Um passo do passo a passo do conteúdo.
class Passo {
  Passo({required this.descricao});

  String descricao;
}

/// O conteúdo de um roteiro: passo a passo + imagens.
class Conteudo {
  Conteudo({
    required this.passoAPasso,
    required this.imagens,
  });

  List<Passo> passoAPasso;
  List<Imagem> imagens;

  Conteudo copy() {
    return Conteudo(
      passoAPasso:
          passoAPasso.map((p) => Passo(descricao: p.descricao)).toList(),
      imagens: imagens.map((i) => Imagem(legenda: i.legenda)).toList(),
    );
  }
}

/// A entidade principal. Um roteiro possui exatamente um conteúdo.
class Roteiro {
  Roteiro({
    required this.id,
    required this.conteudo,
    this.concluido = false,
  });

  final String id;
  Conteudo conteudo;

  /// Ao finalizar um roteiro o aluno ganha uma medalha.
  bool concluido;

  /// Texto usado para exibição e busca "por conteúdo":
  /// primeiro passo do passo a passo.
  String get resumo => conteudo.passoAPasso.isEmpty
      ? "Sem passos ainda"
      : conteudo.passoAPasso.first.descricao;
}

/// Papéis de usuário existentes na especificação.
enum PapelUsuario { aluno, professor, admin }

/// Usuário logado. Só usamos os campos comuns exigidos pelas telas de
/// Login e Cadastro (nome, e-mail, senha) mais o papel.
class Usuario {
  Usuario({
    required this.nome,
    required this.email,
    required this.senha,
    required this.papel,
  });

  final String nome;
  final String email;
  final String senha;
  final PapelUsuario papel;
}
