import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:staircoins/core/errors/exceptions.dart';
import 'package:staircoins/models/user.dart' as app_models;

abstract class FirebaseAuthDatasource {
  /// Retorna o usuário atualmente autenticado ou null se não houver nenhum
  Future<app_models.User?> getCurrentUser();

  /// Realiza login com email e senha
  Future<app_models.User> login(String email, String password);

  /// Registra um novo usuário
  Future<app_models.User> register(
      String name, String email, String password, app_models.UserType type);

  /// Realiza logout do usuário atual
  Future<void> logout();

  /// Verifica se o email já está em uso
  Future<bool> isEmailAlreadyInUse(String email);

  /// Atualiza os dados do usuário
  Future<app_models.User> updateUser(app_models.User user);

  /// Atualiza a quantidade de staircoins do usuário
  Future<app_models.User> updateStaircoins(String userId, int amount);

  /// Adiciona uma turma ao usuário
  Future<app_models.User> addTurmaToUser(String userId, String turmaId);

  /// Remove uma turma do usuário
  Future<app_models.User> removeTurmaFromUser(String userId, String turmaId);

  /// Busca um usuário pelo ID
  Future<app_models.User> getUserById(String userId);
}

class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<app_models.User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        throw ServerException('Usuário não encontrado no Firestore');
      }

      return app_models.User.fromFirestore(userDoc);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
          code: e.code, message: e.message ?? 'Erro de autenticação');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<app_models.User> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw ServerException('Falha ao autenticar usuário');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw ServerException('Usuário não encontrado no Firestore');
      }

      return app_models.User.fromFirestore(userDoc);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw ServerException('Email ou senha inválidos');
      }
      throw FirebaseAuthException(
          code: e.code, message: e.message ?? 'Erro de autenticação');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<app_models.User> register(String name, String email, String password,
      app_models.UserType type) async {
    try {
      // Verificar se o email já está em uso
      final isEmailInUse = await isEmailAlreadyInUse(email);
      if (isEmailInUse) {
        throw EmailDuplicadoException(email);
      }

      // Criar usuário no Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw ServerException('Falha ao criar usuário');
      }

      // Atualizar o nome de exibição
      await user.updateDisplayName(name);

      // Criar documento do usuário no Firestore
      final newUser = app_models.User(
        id: user.uid,
        name: name,
        email: email,
        type: type,
        tipo: type == app_models.UserType.professor ? 'professor' : 'aluno',
        staircoins: 0,
        turmas: [],
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(newUser.toFirestore());

      return newUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw EmailDuplicadoException(email);
      }
      throw FirebaseAuthException(
          code: e.code, message: e.message ?? 'Erro ao registrar usuário');
    } catch (e) {
      if (e is EmailDuplicadoException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Erro ao fazer logout: ${e.toString()}');
    }
  }

  @override
  Future<bool> isEmailAlreadyInUse(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      throw ServerException('Erro ao verificar email: ${e.toString()}');
    }
  }

  @override
  Future<app_models.User> updateUser(app_models.User user) async {
    try {
      // Atualizar no Firestore
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());

      // Atualizar nome de exibição no Auth se necessário
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null &&
          currentUser.uid == user.id &&
          currentUser.displayName != user.name) {
        await currentUser.updateDisplayName(user.name);
      }

      return user;
    } catch (e) {
      throw ServerException('Erro ao atualizar usuário: ${e.toString()}');
    }
  }

  @override
  Future<app_models.User> updateStaircoins(String userId, int amount) async {
    try {
      // Buscar usuário atual
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw ServerException('Usuário não encontrado');
      }

      final user = app_models.User.fromFirestore(userDoc);
      final newStaircoins = user.staircoins + amount;

      // Atualizar staircoins
      await _firestore.collection('users').doc(userId).update({
        'staircoins': newStaircoins,
      });

      return user.copyWith(staircoins: newStaircoins);
    } catch (e) {
      throw ServerException('Erro ao atualizar staircoins: ${e.toString()}');
    }
  }

  @override
  Future<app_models.User> addTurmaToUser(String userId, String turmaId) async {
    try {
      // Buscar usuário atual
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw ServerException('Usuário não encontrado');
      }

      final user = app_models.User.fromFirestore(userDoc);

      // Verificar se a turma já existe na lista
      if (user.turmas.contains(turmaId)) {
        return user;
      }

      final newTurmas = [...user.turmas, turmaId];

      // Atualizar lista de turmas
      await _firestore.collection('users').doc(userId).update({
        'turmas': newTurmas,
      });

      return user.copyWith(turmas: newTurmas);
    } catch (e) {
      throw ServerException(
          'Erro ao adicionar turma ao usuário: ${e.toString()}');
    }
  }

  @override
  Future<app_models.User> removeTurmaFromUser(
      String userId, String turmaId) async {
    try {
      // Buscar usuário atual
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw ServerException('Usuário não encontrado');
      }

      final user = app_models.User.fromFirestore(userDoc);
      final newTurmas = user.turmas.where((id) => id != turmaId).toList();

      // Atualizar lista de turmas
      await _firestore.collection('users').doc(userId).update({
        'turmas': newTurmas,
      });

      return user.copyWith(turmas: newTurmas);
    } catch (e) {
      throw ServerException(
          'Erro ao remover turma do usuário: ${e.toString()}');
    }
  }

  @override
  Future<app_models.User> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw ServerException('Usuário não encontrado');
      }
      return app_models.User.fromFirestore(userDoc);
    } catch (e) {
      throw ServerException('Erro ao buscar usuário por ID: ${e.toString()}');
    }
  }
}
