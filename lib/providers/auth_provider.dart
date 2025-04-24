import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staircoins/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isProfessor => _user?.tipo == 'professor';

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

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('staircoins_user');
      
      if (userData != null) {
        _user = User.fromJson(json.decode(userData));
      }
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      final foundUser = _mockUsers.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => throw Exception('Email ou senha inválidos'),
      );

      // Omite a senha antes de armazenar
      foundUser.remove('password');
      _user = User.fromJson(foundUser);
      
      // Debug para verificar os dados do usuário
      debugPrint('Login realizado: ${_user?.email}, Tipo: ${_user?.tipo}, isProfessor: $isProfessor');

      // Salva no storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('staircoins_user', json.encode(foundUser));
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password, UserType type) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      // Verifica se o email já existe
      if (_mockUsers.any((u) => u['email'] == email)) {
        throw Exception('Este email já está em uso');
      }

      // Cria novo usuário (simulado)
      final newUser = {
        'id': (_mockUsers.length + 1).toString(),
        'name': name,
        'email': email,
        'type': type == UserType.professor ? 'professor' : 'aluno',
        'coins': type == UserType.aluno ? 0 : null,
        'turmas': <String>[],
      };

      // Em um app real, aqui seria feita a chamada para criar o usuário no Firebase
      // Adiciona à lista mockada (apenas para simulação)
      _mockUsers.add({...newUser, 'password': password});

      // Armazena usuário
      _user = User.fromJson(newUser);

      // Salva no storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('staircoins_user', json.encode(newUser));
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('staircoins_user');
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = updatedUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('staircoins_user', json.encode(updatedUser.toJson()));
    } catch (e) {
      debugPrint('Erro ao atualizar usuário: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStaircoins(int amount) async {
    if (_user == null) return;

    final updatedCoins = (_user!.staircoins) + amount;
    final updatedUser = _user!.copyWith(staircoins: updatedCoins);
    _user = updatedUser;

    // Atualizar em SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('staircoins_user', json.encode(updatedUser.toJson()));
    } catch (e) {
      // Ignorar erro
    }

    notifyListeners();
  }
}
