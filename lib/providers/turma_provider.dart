import 'package:flutter/material.dart';
import 'package:staircoins/domain/repositories/turma_repository.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/models/user.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/core/di/injection_container.dart' as di;

class TurmaProvider with ChangeNotifier {
  final TurmaRepository turmaRepository;
  late final AuthProvider authProvider;
  
  List<Turma> _turmas = [];
  bool _isLoading = false;
  String? _errorMessage;

  TurmaProvider({
    required this.turmaRepository,
  }) {
    authProvider = di.sl<AuthProvider>();
    _loadTurmas();
  }

  List<Turma> get turmas => _turmas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadTurmas() async {
    if (authProvider.user == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (authProvider.isProfessor) {
        final result = await turmaRepository.listarTurmasPorProfessor(authProvider.user!.id);
        result.fold(
          (failure) => _errorMessage = failure.message,
          (turmas) => _turmas = turmas,
        );
      } else {
        final result = await turmaRepository.listarTurmasPorAluno(authProvider.user!.id);
        result.fold(
          (failure) => _errorMessage = failure.message,
          (turmas) => _turmas = turmas,
        );
      }
    } catch (e) {
      debugPrint('Erro ao carregar turmas: $e');
      _errorMessage = 'Erro ao carregar turmas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Turma> getMinhasTurmas() {
    final user = authProvider.user;
    if (user == null) return [];
    
    if (authProvider.isProfessor) {
      return _turmas.where((turma) => turma.professorId == user.id).toList();
    } else {
      return _turmas.where((turma) => turma.alunos.contains(user.id)).toList();
    }
  }

  Future<bool> adicionarTurma(String nome, String descricao, String codigo) async {
    final user = authProvider.user;
    if (user == null || user.type != UserType.professor) {
      _errorMessage = 'Apenas professores podem criar turmas';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Criar nova turma
      final novaTurma = Turma(
        id: '', // ID será gerado pelo Firestore
        nome: nome,
        descricao: descricao,
        codigo: codigo.toUpperCase(),
        professorId: user.id,
        alunos: [],
      );

      final result = await turmaRepository.criarTurma(novaTurma);
      
      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          return false;
        },
        (turma) {
          _turmas.add(turma);
          notifyListeners();
          return true;
        }
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> entrarTurma(String codigo) async {
    final user = authProvider.user;
    if (user == null || user.type != UserType.aluno) {
      _errorMessage = 'Apenas alunos podem entrar em turmas';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Busca a turma pelo código
      final turmaPorCodigoResult = await turmaRepository.buscarTurmaPorCodigo(codigo);
      
      return await turmaPorCodigoResult.fold(
        (failure) {
          _errorMessage = failure.message;
          return false;
        },
        (turma) async {
          // Verifica se o aluno já está na turma
          if (turma.alunos.contains(user.id)) {
            _errorMessage = 'Você já está nesta turma';
            return false;
          }
          
          // Adicionar aluno à turma
          final adicionarAlunoResult = await turmaRepository.adicionarAlunoTurma(turma.id, user.id);
          
          return await adicionarAlunoResult.fold(
            (failure) {
              _errorMessage = failure.message;
              return false;
            },
            (turmaNova) async {
              // Adicionar turma ao aluno
              final addTurmaToUserResult = await authProvider.addTurmaToUser(turma.id);
              
              if (addTurmaToUserResult) {
                // Atualiza a lista local
                final index = _turmas.indexWhere((t) => t.id == turma.id);
                if (index >= 0) {
                  _turmas[index] = turmaNova;
                } else {
                  _turmas.add(turmaNova);
                }
                
                notifyListeners();
                return true;
              } else {
                _errorMessage = 'Erro ao adicionar turma ao usuário';
                return false;
              }
            }
          );
        }
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Turma? getTurmaById(String id) {
    try {
      return _turmas.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Turma> get turmasProfessor {
    final user = authProvider.user;
    if (user == null || user.type != UserType.professor) return [];
    
    return _turmas.where((t) => t.professorId == user.id).toList();
  }
  
  // Recarregar turmas
  Future<void> recarregarTurmas() async {
    await _loadTurmas();
  }
}
