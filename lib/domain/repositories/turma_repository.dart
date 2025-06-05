import 'package:dartz/dartz.dart';
import 'package:staircoins/core/errors/failures.dart';
import 'package:staircoins/models/turma.dart';

abstract class TurmaRepository {
  /// Cria uma nova turma
  Future<Either<Failure, Turma>> criarTurma(Turma turma);
  
  /// Lista todas as turmas de um professor
  Future<Either<Failure, List<Turma>>> listarTurmasPorProfessor(String professorId);
  
  /// Lista todas as turmas de um aluno
  Future<Either<Failure, List<Turma>>> listarTurmasPorAluno(String alunoId);
  
  /// Busca uma turma pelo ID
  Future<Either<Failure, Turma>> buscarTurmaPorId(String turmaId);
  
  /// Busca uma turma pelo código
  Future<Either<Failure, Turma>> buscarTurmaPorCodigo(String codigo);
  
  /// Verifica se o código de turma já existe
  Future<Either<Failure, bool>> verificarCodigoTurma(String codigo);
  
  /// Atualiza uma turma existente
  Future<Either<Failure, Turma>> atualizarTurma(Turma turma);
  
  /// Deleta uma turma
  Future<Either<Failure, void>> deletarTurma(String turmaId);
  
  /// Adiciona um aluno à turma
  Future<Either<Failure, Turma>> adicionarAlunoTurma(String turmaId, String alunoId);
  
  /// Remove um aluno da turma
  Future<Either<Failure, Turma>> removerAlunoTurma(String turmaId, String alunoId);
  
  /// Adiciona uma atividade à turma
  Future<Either<Failure, Turma>> adicionarAtividadeTurma(String turmaId, String atividadeId);
  
  /// Remove uma atividade da turma
  Future<Either<Failure, Turma>> removerAtividadeTurma(String turmaId, String atividadeId);
} 