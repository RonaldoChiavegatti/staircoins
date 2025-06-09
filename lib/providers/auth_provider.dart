import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staircoins/domain/repositories/auth_repository.dart';
import 'package:staircoins/models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required this.authRepository}) {
    _loadUserFromStorage();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isProfessor => _user?.tipo == 'professor';
  String? get errorMessage => _errorMessage;

  // Dados mockados para simulação
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Professor Demo',
      'email': 'professor@exemplo.com',
      'password': '123456',
      'type': 'professor',
      'turmas': ['1', '2'],
    },
    {
      'id': '2',
      'name': 'Aluno Demo',
      'email': 'aluno@exemplo.com',
      'password': '123456',
      'type': 'aluno',
      'coins': 150,
      'turmas': ['1'],
    },
  ];

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('staircoins_user');

      if (userData != null) {
        _user = User.fromJson(json.decode(userData));
      } else {
        // Tenta recuperar usuário do Firebase
        final result = await authRepository.getCurrentUser();
        result.fold((failure) => _errorMessage = failure.message, (user) {
          if (user != null) {
            _user = user;
            // Salva no storage
            prefs.setString('staircoins_user', json.encode(user.toJson()));
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
      _errorMessage = 'Erro ao carregar usuário';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authRepository.login(email, password);

      return result.fold((failure) {
        _errorMessage = failure.message;
        return false;
      }, (user) async {
        _user = user;

        // Salva no storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('staircoins_user', json.encode(user.toJson()));

        return true;
      });
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String name, String email, String password, UserType type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authRepository.register(name, email, password, type);

      return result.fold((failure) {
        _errorMessage = failure.message;
        return false;
      }, (user) async {
        _user = user;

        // Salva no storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('staircoins_user', json.encode(user.toJson()));

        return true;
      });
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerStudent(
      String name, String email, String password, List<String> turmaIds) async {
    if (!isProfessor) {
      _errorMessage = 'Apenas professores podem cadastrar alunos';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await authRepository.registerStudent(name, email, password, turmaIds);

      return result.fold((failure) {
        _errorMessage = failure.message;
        return false;
      }, (user) {
        // Não armazenamos o aluno cadastrado como usuário atual
        // apenas retornamos sucesso
        return true;
      });
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authRepository.logout();

      return result.fold((failure) {
        _errorMessage = failure.message;
        return false;
      }, (_) async {
        _user = null;

        // Remove do storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('staircoins_user');

        // Notificar os ouvintes sobre a mudança
        notifyListeners();

        return true;
      });
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(User updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await authRepository.updateUser(updatedUser);

      return result.fold((failure) {
        _errorMessage = failure.message;
        return false;
      }, (user) async {
        _user = user;

        // Atualiza no storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('staircoins_user', json.encode(user.toJson()));

        return true;
      });
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStaircoins(int amount) async {
    if (_user == null) return false;

    try {
      final result = await authRepository.updateStaircoins(_user!.id, amount);

      return result.fold((failure) {
        _errorMessage = failure.message;
        return false;
      }, (updatedUser) {
        _user = updatedUser;

        // Atualiza no storage
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('staircoins_user', json.encode(updatedUser.toJson()));
        });

        notifyListeners();
        return true;
      });
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> addTurmaToUser(String turmaId) async {
    if (!isAuthenticated || _user == null) return false;

    try {
      debugPrint(
          'AuthProvider: Adicionando turma $turmaId ao usuário ${_user!.id}');

      // Verificar se a turma já está na lista do usuário
      if (_user!.turmas.contains(turmaId)) {
        debugPrint('AuthProvider: Turma já está na lista do usuário');
        return true; // Já está adicionada, consideramos sucesso
      }

      // Criar uma nova lista de turmas incluindo a nova
      final turmasAtualizadas = List<String>.from(_user!.turmas);
      turmasAtualizadas.add(turmaId);

      debugPrint(
          'AuthProvider: Turmas antes: ${_user!.turmas.length}, depois: ${turmasAtualizadas.length}');

      // Atualizar o usuário com a nova lista de turmas
      final updatedUser = _user!.copyWith(turmas: turmasAtualizadas);

      // Chamar o repositório para atualizar o usuário no Firebase
      final result = await authRepository.updateUser(updatedUser);

      return result.fold(
        (failure) {
          debugPrint(
              'AuthProvider: Erro ao adicionar turma: ${failure.message}');
          _errorMessage = failure.message;
          return false;
        },
        (user) {
          debugPrint('AuthProvider: Turma adicionada com sucesso');
          _user = user;

          // Atualiza no storage
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('staircoins_user', json.encode(user.toJson()));
          });

          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      debugPrint('AuthProvider: Exceção ao adicionar turma: $e');
      _errorMessage = e.toString();
      return false;
    }
  }
}
