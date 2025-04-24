enum AtividadeStatus { pendente, entregue, atrasado }

class Atividade {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataEntrega;
  final int pontuacao;
  final AtividadeStatus status;
  final String turmaId;

  Atividade({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataEntrega,
    required this.pontuacao,
    required this.status,
    required this.turmaId,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataEntrega: DateTime.parse(json['dataEntrega']),
      pontuacao: json['pontuacao'],
      status: AtividadeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AtividadeStatus.pendente,
      ),
      turmaId: json['turmaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'dataEntrega': dataEntrega.toIso8601String(),
      'pontuacao': pontuacao,
      'status': status.toString().split('.').last,
      'turmaId': turmaId,
    };
  }

  Atividade copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataEntrega,
    int? pontuacao,
    AtividadeStatus? status,
    String? turmaId,
  }) {
    return Atividade(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      pontuacao: pontuacao ?? this.pontuacao,
      status: status ?? this.status,
      turmaId: turmaId ?? this.turmaId,
    );
  }
}
