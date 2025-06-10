import 'package:cloud_firestore/cloud_firestore.dart';

class EntregaAtividade {
  final String id;
  final String atividadeId;
  final String alunoId;
  final DateTime dataEntrega;
  final String? anexoUrl;
  final String status; // 'entregue', 'nao_entregue', 'atrasado'
  final double? nota;
  final String? feedback;
  final String? originalFileName;

  EntregaAtividade({
    required this.id,
    required this.atividadeId,
    required this.alunoId,
    required this.dataEntrega,
    this.anexoUrl,
    required this.status,
    this.nota,
    this.feedback,
    this.originalFileName,
  });

  factory EntregaAtividade.fromJson(Map<String, dynamic> json) {
    return EntregaAtividade(
      id: json['id'] as String,
      atividadeId: json['atividadeId'] as String,
      alunoId: json['alunoId'] as String,
      dataEntrega: (json['dataEntrega'] is Timestamp)
          ? (json['dataEntrega'] as Timestamp).toDate()
          : DateTime.parse(json['dataEntrega'] as String),
      anexoUrl: json['anexoUrl'] as String?,
      status: json['status'] as String,
      nota: json['nota'] != null ? (json['nota'] as num).toDouble() : null,
      feedback: json['feedback'] as String?,
      originalFileName: json['originalFileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'atividadeId': atividadeId,
      'alunoId': alunoId,
      'dataEntrega': dataEntrega.toIso8601String(),
      'anexoUrl': anexoUrl,
      'status': status,
      'nota': nota,
      'feedback': feedback,
      'originalFileName': originalFileName,
    };
  }

  EntregaAtividade copyWith({
    String? id,
    String? atividadeId,
    String? alunoId,
    DateTime? dataEntrega,
    String? anexoUrl,
    String? status,
    double? nota,
    String? feedback,
    String? originalFileName,
  }) {
    return EntregaAtividade(
      id: id ?? this.id,
      atividadeId: atividadeId ?? this.atividadeId,
      alunoId: alunoId ?? this.alunoId,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      anexoUrl: anexoUrl ?? this.anexoUrl,
      status: status ?? this.status,
      nota: nota ?? this.nota,
      feedback: feedback ?? this.feedback,
      originalFileName: originalFileName ?? this.originalFileName,
    );
  }
}
