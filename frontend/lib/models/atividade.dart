enum CategoriaAtividade { hardware, programacao, montagem }

extension CategoriaAtividadeExtension on CategoriaAtividade {
  String get valor {
    switch (this) {
      case CategoriaAtividade.hardware:
        return 'hardware';
      case CategoriaAtividade.programacao:
        return 'programacao';
      case CategoriaAtividade.montagem:
        return 'montagem';
    }
  }

  static CategoriaAtividade fromString(String valor) {
    return CategoriaAtividade.values.firstWhere((c) => c.valor == valor);
  }
}

class Atividade {
  final int? id;
  final String titulo;
  final String? descricao;
  final CategoriaAtividade categoria;
  final bool concluida;
  final DateTime? dataPrevista;

  Atividade({
    this.id,
    required this.titulo,
    this.descricao,
    required this.categoria,
    this.concluida = false,
    this.dataPrevista,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      categoria: CategoriaAtividadeExtension.fromString(json['categoria']),
      concluida: json['concluida'] ?? false,
      dataPrevista: json['data_prevista'] != null
          ? DateTime.parse(json['data_prevista'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.valor,
      'concluida': concluida,
      'data_prevista': dataPrevista?.toIso8601String().split('T')[0],
    };
  }
}