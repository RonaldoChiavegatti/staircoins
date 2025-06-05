import 'package:dartz/dartz.dart';
import 'package:staircoins/core/errors/exceptions.dart';
import 'package:staircoins/core/errors/failures.dart';
import 'package:staircoins/core/network/network_info.dart';
import 'package:staircoins/data/datasources/firebase_turma_datasource.dart';
import 'package:staircoins/domain/repositories/turma_repository.dart';
import 'package:staircoins/models/turma.dart';

class FirebaseTurmaRepositoryImpl implements TurmaRepository {
  final FirebaseTurmaDatasource datasource;
  final NetworkInfo networkInfo;
  
  FirebaseTurmaRepositoryImpl({
    required this.datasource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, Turma>> criarTurma(Turma turma) async {
    if (await networkInfo.isConnected) {
      try {
        final novaTurma = await datasource.criarTurma(turma);
        return Right(novaTurma);
      } on CodigoTurmaDuplicadoException catch (e) {
        return Left(CodigoTurmaExistenteFailure(e.codigo));
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
  Future<Either<Failure, List<Turma>>> listarTurmasPorProfessor(String professorId) async {
    if (await networkInfo.isConnected) {
      try {
        final turmas = await datasource.listarTurmasPorProfessor(professorId);
        return Right(turmas);
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
  Future<Either<Failure, List<Turma>>> listarTurmasPorAluno(String alunoId) async {
    if (await networkInfo.isConnected) {
      try {
        final turmas = await datasource.listarTurmasPorAluno(alunoId);
        return Right(turmas);
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
  Future<Either<Failure, Turma>> buscarTurmaPorId(String turmaId) async {
    if (await networkInfo.isConnected) {
      try {
        final turma = await datasource.buscarTurmaPorId(turmaId);
        return Right(turma);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
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
  Future<Either<Failure, Turma>> buscarTurmaPorCodigo(String codigo) async {
    if (await networkInfo.isConnected) {
      try {
        final turma = await datasource.buscarTurmaPorCodigo(codigo);
        return Right(turma);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
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
  Future<Either<Failure, bool>> verificarCodigoTurma(String codigo) async {
    if (await networkInfo.isConnected) {
      try {
        final existe = await datasource.verificarCodigoTurma(codigo);
        return Right(existe);
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
  Future<Either<Failure, Turma>> atualizarTurma(Turma turma) async {
    if (await networkInfo.isConnected) {
      try {
        final turmaAtualizada = await datasource.atualizarTurma(turma);
        return Right(turmaAtualizada);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
      } on CodigoTurmaDuplicadoException catch (e) {
        return Left(CodigoTurmaExistenteFailure(e.codigo));
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
  Future<Either<Failure, void>> deletarTurma(String turmaId) async {
    if (await networkInfo.isConnected) {
      try {
        await datasource.deletarTurma(turmaId);
        return const Right(null);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
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
  Future<Either<Failure, Turma>> adicionarAlunoTurma(String turmaId, String alunoId) async {
    if (await networkInfo.isConnected) {
      try {
        final turmaAtualizada = await datasource.adicionarAlunoTurma(turmaId, alunoId);
        return Right(turmaAtualizada);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
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
  Future<Either<Failure, Turma>> removerAlunoTurma(String turmaId, String alunoId) async {
    if (await networkInfo.isConnected) {
      try {
        final turmaAtualizada = await datasource.removerAlunoTurma(turmaId, alunoId);
        return Right(turmaAtualizada);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
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
  Future<Either<Failure, Turma>> adicionarAtividadeTurma(String turmaId, String atividadeId) async {
    if (await networkInfo.isConnected) {
      try {
        final turmaAtualizada = await datasource.adicionarAtividadeTurma(turmaId, atividadeId);
        return Right(turmaAtualizada);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
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
  Future<Either<Failure, Turma>> removerAtividadeTurma(String turmaId, String atividadeId) async {
    if (await networkInfo.isConnected) {
      try {
        final turmaAtualizada = await datasource.removerAtividadeTurma(turmaId, atividadeId);
        return Right(turmaAtualizada);
      } on TurmaNaoEncontradaException catch (e) {
        return Left(TurmaNaoEncontradaFailure(e.codigo));
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