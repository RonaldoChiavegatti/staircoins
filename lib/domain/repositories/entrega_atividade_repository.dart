import 'package:dartz/dartz.dart';
import '../../models/entrega_atividade.dart';

abstract class EntregaAtividadeRepository {
  Future<Either<Exception, void>> entregarAtividade(EntregaAtividade entrega);
  Future<Either<Exception, void>> atualizarEntrega(EntregaAtividade entrega);
  Future<Either<Exception, List<EntregaAtividade>>> getEntregasByAtividade(
      String atividadeId);
  Future<Either<Exception, List<EntregaAtividade>>> getEntregasByAluno(
      String alunoId);
  Future<Either<Exception, EntregaAtividade?>> getEntregaByAtividadeAndAluno(
      String atividadeId, String alunoId);
}
