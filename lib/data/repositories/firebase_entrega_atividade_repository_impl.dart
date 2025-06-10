import 'package:dartz/dartz.dart';
import '../../models/entrega_atividade.dart';
import '../../domain/repositories/entrega_atividade_repository.dart';
import '../datasources/firebase_entrega_atividade_datasource.dart';
import 'dart:io';
import 'dart:typed_data';

class FirebaseEntregaAtividadeRepositoryImpl
    implements EntregaAtividadeRepository {
  final FirebaseEntregaAtividadeDatasource datasource;

  FirebaseEntregaAtividadeRepositoryImpl(this.datasource);

  @override
  Future<Either<Exception, void>> entregarAtividade(
      EntregaAtividade entrega) async {
    try {
      await datasource.entregarAtividade(entrega);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> atualizarEntrega(
      EntregaAtividade entrega) async {
    try {
      await datasource.atualizarEntrega(entrega);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<EntregaAtividade>>> getEntregasByAtividade(
      String atividadeId) async {
    try {
      final result = await datasource.getEntregasByAtividade(atividadeId);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<EntregaAtividade>>> getEntregasByAluno(
      String alunoId) async {
    try {
      final result = await datasource.getEntregasByAluno(alunoId);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, EntregaAtividade?>> getEntregaByAtividadeAndAluno(
      String atividadeId, String alunoId) async {
    try {
      final result =
          await datasource.getEntregaByAtividadeAndAluno(atividadeId, alunoId);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, String>> uploadAnexo(
      String entregaId, File file, String originalFileName) async {
    try {
      final result =
          await datasource.uploadAnexo(entregaId, file, originalFileName);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, String>> uploadAnexoWeb(
      String entregaId, Uint8List fileBytes, String originalFileName) async {
    try {
      final result = await datasource.uploadAnexoWeb(
          entregaId, fileBytes, originalFileName);
      return Right(result);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
