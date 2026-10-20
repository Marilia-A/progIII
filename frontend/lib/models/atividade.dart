class Atividade {
  Atividade({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.categoria,
    required this.concluida,
    this.dataPrevista,
  });

  final int id;
  final String titulo;
  final String? descricao;
  final String categoria;
  final bool concluida;
  final DateTime? dataPrevista;

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      categoria: json['categoria'],
      concluida: json['concluida'],
      dataPrevista: json['data_prevista'] == null
          ? null
          : DateTime.parse(json['data_prevista']),
    );
  }

  String get nomeDaCategoria {
    switch (categoria) {
      case 'hardware':
        return 'Hardware';
      case 'programacao':
        return 'Programação';
      case 'montagem':
        return 'Montagem';
      default:
        return categoria;
    }
  }

  String get dataFormatada {
    final d = dataPrevista;
    if (d == null) return 'Sem data prevista';
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year}';
  }
}