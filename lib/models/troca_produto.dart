import 'package:cloud_firestore/cloud_firestore.dart';

class TrocaProduto {
  final String id;
  final String produtoId;
  final String alunoId;
  final String codigoTroca;
  final DateTime data;
  final String status; // Ex: 'pendente', 'concluida'

  TrocaProduto({
    required this.id,
    required this.produtoId,
    required this.alunoId,
    required this.codigoTroca,
    required this.data,
    required this.status,
  });

  factory TrocaProduto.fromJson(Map<String, dynamic> json) {
    return TrocaProduto(
      id: json['id'],
      produtoId: json['produtoId'],
      alunoId: json['alunoId'],
      codigoTroca: json['codigoTroca'],
      data: json['data'] is Timestamp
          ? (json['data'] as Timestamp).toDate()
          : DateTime.parse(json['data'].toString()),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produtoId': produtoId,
      'alunoId': alunoId,
      'codigoTroca': codigoTroca,
      'data': data.toIso8601String(),
      'status': status,
    };
  }
}
