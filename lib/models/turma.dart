import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Turma extends Equatable {
  final String id;
  final String nome;
  final String descricao;
  final String professorId;
  final List<String> alunos;
  final List<String> atividades;
  final String codigo;
  final DateTime? createdAt;

  const Turma({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.professorId,
    required this.alunos,
    this.atividades = const [],
    required this.codigo,
    this.createdAt,
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
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] is Timestamp 
              ? (json['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(json['createdAt'].toString()))
          : null,
    );
  }

  factory Turma.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Turma(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      professorId: data['professorId'] ?? '',
      alunos: data['alunos'] != null 
          ? List<String>.from(data['alunos']) 
          : [],
      atividades: data['atividades'] != null 
          ? List<String>.from(data['atividades']) 
          : [],
      codigo: data['codigo'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
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
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'descricao': descricao,
      'professorId': professorId,
      'alunos': alunos,
      'atividades': atividades,
      'codigo': codigo,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
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
    DateTime? createdAt,
  }) {
    return Turma(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      professorId: professorId ?? this.professorId,
      alunos: alunos ?? this.alunos,
      atividades: atividades ?? this.atividades,
      codigo: codigo ?? this.codigo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id, 
    nome, 
    descricao, 
    professorId, 
    alunos, 
    atividades, 
    codigo, 
    createdAt
  ];
}
