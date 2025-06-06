import 'package:dartz/dartz.dart';
import 'package:staircoins/core/errors/exceptions.dart';
import 'package:staircoins/core/errors/failures.dart';
import 'package:staircoins/core/network/network_info.dart';
import 'package:staircoins/data/datasources/firebase_auth_datasource.dart';
import 'package:staircoins/domain/repositories/auth_repository.dart';
import 'package:staircoins/models/user.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource datasource;
  final NetworkInfo networkInfo;

  FirebaseAuthRepositoryImpl({
    required this.datasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await datasource.getCurrentUser();
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on FirebaseAuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await datasource.login(email, password);
        return Right(user);
      } on ServerException catch (e) {
        if (e.message.contains('Email ou senha inválidos')) {
          return Left(const CredenciaisInvalidasFailure());
        }
        return Left(ServerFailure(e.message));
      } on FirebaseAuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register(
      String name, String email, String password, UserType type) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await datasource.register(name, email, password, type);
        return Right(user);
      } on EmailDuplicadoException catch (e) {
        return Left(EmailJaExisteFailure(e.toString()));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return Left(const EmailJaExisteFailure());
        }
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> registerStudent(
      String name, String email, String password, List<String> turmaIds) async {
    if (await networkInfo.isConnected) {
      try {
        // Registra o aluno como um usuário do tipo aluno
        final user =
            await datasource.register(name, email, password, UserType.aluno);

        // Adiciona o aluno às turmas selecionadas
        User updatedUser = user;
        for (final turmaId in turmaIds) {
          updatedUser = await datasource.addTurmaToUser(user.id, turmaId);
        }

        // Retorna o usuário atualizado com as turmas
        return Right(updatedUser);
      } on EmailDuplicadoException catch (e) {
        return Left(EmailJaExisteFailure(e.toString()));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return Left(const EmailJaExisteFailure());
        }
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        await datasource.logout();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailAlreadyInUse(String email) async {
    if (await networkInfo.isConnected) {
      try {
        final isInUse = await datasource.isEmailAlreadyInUse(email);
        return Right(isInUse);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await datasource.updateUser(user);
        return Right(updatedUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateStaircoins(
      String userId, int amount) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await datasource.updateStaircoins(userId, amount);
        return Right(updatedUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> addTurmaToUser(
      String userId, String turmaId) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await datasource.addTurmaToUser(userId, turmaId);
        return Right(updatedUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> removeTurmaFromUser(
      String userId, String turmaId) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser =
            await datasource.removeTurmaFromUser(userId, turmaId);
        return Right(updatedUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }
}
