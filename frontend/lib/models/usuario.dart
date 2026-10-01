class Usuario {
  Usuario({required this.id, required this.nome, required this.email});

  final int id;
  final String nome;
  final String email;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(id: json['id'], nome: json['nome'], email: json['email']);
  }
}