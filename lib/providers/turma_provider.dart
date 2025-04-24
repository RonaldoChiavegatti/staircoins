import 'package:flutter/material.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/models/user.dart';
import 'package:uuid/uuid.dart';

class TurmaProvider with ChangeNotifier {
  final User? _user;
  List<Turma> _turmas = [];
  bool _isLoading = false;

  TurmaProvider(this._user) {
    _loadTurmas();
  }

  List<Turma> get turmas => _turmas;
  bool get isLoading => _isLoading;

  // Dados mockados para simulação
  final List<Map<String, dynamic>> _mockTurmas = [
    {
      'id': '1',
      'nome': 'Matemática - 9º Ano',
      'descricao': 'Turma de matemática do 9º ano do ensino fundamental',
      'professorId': '1',
      'alunos': ['2'],
      'codigo': 'MAT9A',
    },
    {
      'id': '2',
      'nome': 'História - 8º Ano',
      'descricao': 'Turma de história do 8º ano do ensino fundamental',
      'professorId': '1',
      'alunos': [],
      'codigo': 'HIS8A',
    },
  ];

  Future<void> _loadTurmas() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(milliseconds: 500));

      _turmas = _mockTurmas.map((t) => Turma.fromJson(t)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar turmas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Turma> getMinhasTurmas() {
    if (_user == null) return [];
    return _turmas.where((turma) => _user!.turmas.contains(turma.id)).toList();
  }

  Future<void> adicionarTurma(String nome, String descricao, String codigo) async {
    if (_user == null || _user!.type != UserType.professor) {
      throw Exception('Apenas professores podem criar turmas');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      // Verifica se o código já existe
      if (_turmas.any((t) => t.codigo == codigo)) {
        throw Exception('Este código de turma já está em uso');
      }

      // Cria nova turma
      final novaTurma = Turma(
        id: const Uuid().v4(),
        nome: nome,
        descricao: descricao,
        codigo: codigo,
        professorId: _user!.id,
        alunos: [],
      );

      // Adiciona à lista de turmas
      _turmas.add(novaTurma);
      _mockTurmas.add(novaTurma.toJson());

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> entrarTurma(String codigo) async {
    if (_user == null || _user!.type != UserType.aluno) {
      throw Exception('Apenas alunos podem entrar em turmas');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      // Busca a turma pelo código
      final turmaIndex = _turmas.indexWhere((t) => t.codigo == codigo);
      if (turmaIndex == -1) {
        throw Exception('Turma não encontrada');
      }

      final turma = _turmas[turmaIndex];

      // Verifica se o aluno já está na turma
      if (turma.alunos.contains(_user!.id)) {
        throw Exception('Você já está nesta turma');
      }

      // Adiciona o aluno à turma
      final updatedTurma = turma.copyWith(
        alunos: [...turma.alunos, _user!.id],
      );

      _turmas[turmaIndex] = updatedTurma;
      _mockTurmas[turmaIndex] = updatedTurma.toJson();

      notifyListeners();
    } catch (e) {
      rethrow;
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

  List<Turma> get turmasProfessor => _turmas.where((t) => t.professorId == _user?.id).toList();
}
