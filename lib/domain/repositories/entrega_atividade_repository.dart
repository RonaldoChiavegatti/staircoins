import 'package:dartz/dartz.dart';
import '../../models/entrega_atividade.dart';
import 'dart:io';
import 'dart:typed_data';

abstract class EntregaAtividadeRepository {
  Future<Either<Exception, void>> entregarAtividade(EntregaAtividade entrega);
  Future<Either<Exception, void>> atualizarEntrega(EntregaAtividade entrega);
  Future<Either<Exception, List<EntregaAtividade>>> getEntregasByAtividade(
      String atividadeId);
  Future<Either<Exception, List<EntregaAtividade>>> getEntregasByAluno(
      String alunoId);
  Future<Either<Exception, EntregaAtividade?>> getEntregaByAtividadeAndAluno(
      String atividadeId, String alunoId);
  Future<Either<Exception, String>> uploadAnexo(
      String entregaId, File file, String originalFileName);
  Future<Either<Exception, String>> uploadAnexoWeb(
      String entregaId, Uint8List fileBytes, String originalFileName);
}
