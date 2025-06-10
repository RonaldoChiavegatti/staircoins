import 'dart:io';
import 'package:flutter/material.dart';
import '../models/entrega_atividade.dart';
import '../domain/repositories/entrega_atividade_repository.dart';
import '../data/datasources/firebase_entrega_atividade_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:staircoins/domain/repositories/auth_repository.dart';
import 'package:staircoins/models/user.dart';

class EntregaAtividadeProvider with ChangeNotifier {
  final EntregaAtividadeRepository repository;
  final FirebaseEntregaAtividadeDatasource datasource;
  final AuthRepository authRepository;

  List<EntregaAtividade> _entregas = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, User> _alunosCache = {};

  List<EntregaAtividade> get entregas => _entregas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, User> get alunosCache => _alunosCache;

  EntregaAtividadeProvider({
    required this.repository,
    required this.datasource,
    required this.authRepository,
  });

  Future<void> fetchEntregasByAtividade(String atividadeId) async {
    _isLoading = true;
    debugPrint(
        'EntregaAtividadeProvider: Buscando entregas para atividadeId: $atividadeId');
    notifyListeners();
    final result = await repository.getEntregasByAtividade(atividadeId);
    await result.fold(
      (l) {
        _error = l.toString();
        debugPrint(
            'EntregaAtividadeProvider: Erro ao buscar entregas: $_error');
      },
      (r) async {
        _entregas = r;
        debugPrint(
            'EntregaAtividadeProvider: ${r.length} entregas encontradas.');
        // Fetch aluno details for each entrega
        for (var entrega in _entregas) {
          if (!_alunosCache.containsKey(entrega.alunoId)) {
            debugPrint(
                'EntregaAtividadeProvider: Buscando aluno ${entrega.alunoId}...');
            final userResult =
                await authRepository.getUserById(entrega.alunoId);
            userResult.fold(
              (l) => debugPrint(
                  'EntregaAtividadeProvider: Erro ao buscar aluno ${entrega.alunoId}: ${l.toString()}'),
              (user) {
                _alunosCache[user.id] = user;
                debugPrint(
                    'EntregaAtividadeProvider: Aluno ${user.name} (${user.id}) adicionado ao cache.');
              },
            );
          } else {
            debugPrint(
                'EntregaAtividadeProvider: Aluno ${entrega.alunoId} já está no cache.');
          }
        }
      },
    );
    _isLoading = false;
    notifyListeners();
    debugPrint('EntregaAtividadeProvider: Busca de entregas concluída.');
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
      {File? file, Uint8List? fileBytes, String? originalFileName}) async {
    try {
      if (originalFileName == null || originalFileName.isEmpty) {
        throw Exception('Original file name cannot be null or empty');
      }

      if (kIsWeb) {
        if (fileBytes == null) {
          throw Exception('File bytes cannot be null on web');
        }
        final result = await repository.uploadAnexoWeb(
            entregaId, fileBytes, originalFileName);
        return result.fold(
          (l) {
            _error = l.toString();
            notifyListeners();
            return null;
          },
          (r) => r,
        );
      } else {
        if (file == null) {
          throw Exception('File cannot be null on non-web platforms');
        }
        final result =
            await repository.uploadAnexo(entregaId, file, originalFileName);
        return result.fold(
          (l) {
            _error = l.toString();
            notifyListeners();
            return null;
          },
          (r) => r,
        );
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

  Future<void> adicionarStaircoinsAoAluno(String alunoId, int amount) async {
    _isLoading = true;
    notifyListeners();
    final result = await authRepository.updateStaircoins(alunoId, amount);
    result.fold(
      (l) => _error = l.toString(),
      (r) => debugPrint(
          'Staircoins do aluno ${alunoId} atualizados para ${r.staircoins}'),
    );
    _isLoading = false;
    notifyListeners();
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }
}
