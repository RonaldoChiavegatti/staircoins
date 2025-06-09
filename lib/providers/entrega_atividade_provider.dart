import 'dart:io';
import 'package:flutter/material.dart';
import '../models/entrega_atividade.dart';
import '../domain/repositories/entrega_atividade_repository.dart';
import '../data/datasources/firebase_entrega_atividade_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class EntregaAtividadeProvider with ChangeNotifier {
  final EntregaAtividadeRepository repository;
  final FirebaseEntregaAtividadeDatasource datasource;

  List<EntregaAtividade> _entregas = [];
  bool _isLoading = false;
  String? _error;

  List<EntregaAtividade> get entregas => _entregas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EntregaAtividadeProvider({
    required this.repository,
    required this.datasource,
  });

  Future<void> fetchEntregasByAtividade(String atividadeId) async {
    _isLoading = true;
    notifyListeners();
    final result = await repository.getEntregasByAtividade(atividadeId);
    result.fold(
      (l) => _error = l.toString(),
      (r) => _entregas = r,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEntregasByAluno(String alunoId) async {
    _isLoading = true;
    notifyListeners();
    final result = await repository.getEntregasByAluno(alunoId);
    result.fold(
      (l) => _error = l.toString(),
      (r) => _entregas = r,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> uploadAnexo(String entregaId,
      {File? file, Uint8List? fileBytes}) async {
    try {
      if (kIsWeb) {
        if (fileBytes == null) {
          throw Exception('File bytes cannot be null on web');
        }
        return await datasource.uploadAnexoWeb(entregaId, fileBytes);
      } else {
        if (file == null) {
          throw Exception('File cannot be null on non-web platforms');
        }
        return await datasource.uploadAnexo(entregaId, file);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> entregarAtividade(EntregaAtividade entrega) async {
    _isLoading = true;
    notifyListeners();
    final result = await repository.entregarAtividade(entrega);
    result.fold(
      (l) => _error = l.toString(),
      (r) => null,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> atualizarEntrega(EntregaAtividade entrega) async {
    _isLoading = true;
    notifyListeners();
    final result = await repository.atualizarEntrega(entrega);
    result.fold(
      (l) => _error = l.toString(),
      (r) => null,
    );
    _isLoading = false;
    notifyListeners();
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }
}
