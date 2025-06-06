import 'package:dartz/dartz.dart';
import 'package:staircoins/core/errors/failures.dart';
import 'package:staircoins/models/user.dart';

abstract class AuthRepository {
  /// Retorna o usuário atualmente autenticado ou null se não houver nenhum
  Future<Either<Failure, User?>> getCurrentUser();

  /// Realiza login com email e senha
  Future<Either<Failure, User>> login(String email, String password);

  /// Registra um novo usuário
  Future<Either<Failure, User>> register(
      String name, String email, String password, UserType type);

  /// Registra um novo aluno pelo professor
  Future<Either<Failure, User>> registerStudent(
      String name, String email, String password, List<String> turmaIds);

  /// Realiza logout do usuário atual
  Future<Either<Failure, void>> logout();

  /// Verifica se o email já está em uso
  Future<Either<Failure, bool>> isEmailAlreadyInUse(String email);

  /// Atualiza os dados do usuário
  Future<Either<Failure, User>> updateUser(User user);

  /// Atualiza a quantidade de staircoins do usuário
  Future<Either<Failure, User>> updateStaircoins(String userId, int amount);

  /// Adiciona uma turma ao usuário
  Future<Either<Failure, User>> addTurmaToUser(String userId, String turmaId);

  /// Remove uma turma do usuário
  Future<Either<Failure, User>> removeTurmaFromUser(
      String userId, String turmaId);
}
