class Turma {
  final String id;
  final String nome;
  final String descricao;
  final String professorId;
  final List<String> alunos;
  final List<String> atividades;
  final String codigo;

  Turma({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.professorId,
    required this.alunos,
    this.atividades = const [],
    required this.codigo,
  });

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      professorId: json['professorId'],
      alunos: List<String>.from(json['alunos']),
      atividades: json['atividades'] != null 
          ? List<String>.from(json['atividades']) 
          : [],
      codigo: json['codigo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'professorId': professorId,
      'alunos': alunos,
      'atividades': atividades,
      'codigo': codigo,
    };
  }

  Turma copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? professorId,
    List<String>? alunos,
    List<String>? atividades,
    String? codigo,
  }) {
    return Turma(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      professorId: professorId ?? this.professorId,
      alunos: alunos ?? this.alunos,
      atividades: atividades ?? this.atividades,
      codigo: codigo ?? this.codigo,
    );
  }
}
