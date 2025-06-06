import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staircoins/core/errors/exceptions.dart';
import 'package:staircoins/models/turma.dart';

abstract class FirebaseTurmaDatasource {
  /// Cria uma nova turma
  Future<Turma> criarTurma(Turma turma);

  /// Lista todas as turmas de um professor
  Future<List<Turma>> listarTurmasPorProfessor(String professorId);

  /// Lista todas as turmas de um aluno
  Future<List<Turma>> listarTurmasPorAluno(String alunoId);

  /// Busca uma turma pelo ID
  Future<Turma> buscarTurmaPorId(String turmaId);

  /// Busca uma turma pelo código
  Future<Turma> buscarTurmaPorCodigo(String codigo);

  /// Verifica se o código de turma já existe
  Future<bool> verificarCodigoTurma(String codigo);

  /// Atualiza uma turma existente
  Future<Turma> atualizarTurma(Turma turma);

  /// Deleta uma turma
  Future<void> deletarTurma(String turmaId);

  /// Adiciona um aluno à turma
  Future<Turma> adicionarAlunoTurma(String turmaId, String alunoId);

  /// Remove um aluno da turma
  Future<Turma> removerAlunoTurma(String turmaId, String alunoId);

  /// Adiciona uma atividade à turma
  Future<Turma> adicionarAtividadeTurma(String turmaId, String atividadeId);

  /// Remove uma atividade da turma
  Future<Turma> removerAtividadeTurma(String turmaId, String atividadeId);
}

class FirebaseTurmaDatasourceImpl implements FirebaseTurmaDatasource {
  final FirebaseFirestore _firestore;

  FirebaseTurmaDatasourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<Turma> criarTurma(Turma turma) async {
    try {
      // Verificar se o código já existe
      final codigoExiste = await verificarCodigoTurma(turma.codigo);
      if (codigoExiste) {
        throw CodigoTurmaDuplicadoException(turma.codigo);
      }

      // Usar transação para garantir atomicidade
      return await _firestore.runTransaction<Turma>((transaction) async {
        // Criar documento com ID gerado automaticamente
        final docRef = _firestore.collection('turmas').doc();

        // Criar turma com ID gerado
        final novaTurma = Turma(
          id: docRef.id,
          nome: turma.nome,
          descricao: turma.descricao,
          professorId: turma.professorId,
          alunos: turma.alunos,
          atividades: turma.atividades,
          codigo: turma.codigo,
          createdAt: DateTime.now(),
        );

        // Adicionar ao Firestore
        transaction.set(docRef, novaTurma.toFirestore());

        return novaTurma;
      });
    } on CodigoTurmaDuplicadoException {
      rethrow;
    } catch (e) {
      throw ServerException('Erro ao criar turma: ${e.toString()}');
    }
  }

  @override
  Future<List<Turma>> listarTurmasPorProfessor(String professorId) async {
    try {
      // Restaurar ordenação após criar o índice composto
      final snapshot = await _firestore
          .collection('turmas')
          .where('professorId', isEqualTo: professorId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Turma.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(
          'Erro ao listar turmas do professor: ${e.toString()}');
    }
  }

  @override
  Future<List<Turma>> listarTurmasPorAluno(String alunoId) async {
    try {
      // Restaurar ordenação após criar o índice composto
      final snapshot = await _firestore
          .collection('turmas')
          .where('alunos', arrayContains: alunoId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Turma.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Erro ao listar turmas do aluno: ${e.toString()}');
    }
  }

  @override
  Future<Turma> buscarTurmaPorId(String turmaId) async {
    try {
      final doc = await _firestore.collection('turmas').doc(turmaId).get();

      if (!doc.exists) {
        throw TurmaNaoEncontradaException('ID não encontrado');
      }

      return Turma.fromFirestore(doc);
    } catch (e) {
      if (e is TurmaNaoEncontradaException) {
        rethrow;
      }
      throw ServerException('Erro ao buscar turma: ${e.toString()}');
    }
  }

  @override
  Future<Turma> buscarTurmaPorCodigo(String codigo) async {
    try {
      final snapshot = await _firestore
          .collection('turmas')
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw TurmaNaoEncontradaException(codigo);
      }

      return Turma.fromFirestore(snapshot.docs.first);
    } catch (e) {
      if (e is TurmaNaoEncontradaException) {
        rethrow;
      }
      throw ServerException('Erro ao buscar turma por código: ${e.toString()}');
    }
  }

  @override
  Future<bool> verificarCodigoTurma(String codigo) async {
    try {
      final snapshot = await _firestore
          .collection('turmas')
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException(
          'Erro ao verificar código de turma: ${e.toString()}');
    }
  }

  @override
  Future<Turma> atualizarTurma(Turma turma) async {
    try {
      // Verificar se a turma existe
      final turmaExiste =
          await _firestore.collection('turmas').doc(turma.id).get();
      if (!turmaExiste.exists) {
        throw TurmaNaoEncontradaException('ID não encontrado');
      }

      // Verificar se o código já existe (apenas se foi alterado)
      final turmaDoBanco = Turma.fromFirestore(turmaExiste);
      if (turmaDoBanco.codigo != turma.codigo) {
        final codigoExiste = await verificarCodigoTurma(turma.codigo);
        if (codigoExiste) {
          throw CodigoTurmaDuplicadoException(turma.codigo);
        }
      }

      // Atualizar turma
      await _firestore
          .collection('turmas')
          .doc(turma.id)
          .update(turma.toFirestore());

      return turma;
    } on TurmaNaoEncontradaException {
      rethrow;
    } on CodigoTurmaDuplicadoException {
      rethrow;
    } catch (e) {
      throw ServerException('Erro ao atualizar turma: ${e.toString()}');
    }
  }

  @override
  Future<void> deletarTurma(String turmaId) async {
    try {
      // Verificar se a turma existe
      final turmaExiste =
          await _firestore.collection('turmas').doc(turmaId).get();
      if (!turmaExiste.exists) {
        throw TurmaNaoEncontradaException('ID não encontrado');
      }

      // Deletar turma
      await _firestore.collection('turmas').doc(turmaId).delete();
    } on TurmaNaoEncontradaException {
      rethrow;
    } catch (e) {
      throw ServerException('Erro ao deletar turma: ${e.toString()}');
    }
  }

  @override
  Future<Turma> adicionarAlunoTurma(String turmaId, String alunoId) async {
    try {
      // Buscar turma atual
      final turmaDoc = await _firestore.collection('turmas').doc(turmaId).get();

      if (!turmaDoc.exists) {
        throw TurmaNaoEncontradaException('ID não encontrado');
      }

      final turma = Turma.fromFirestore(turmaDoc);

      // Verificar se o aluno já está na turma
      if (turma.alunos.contains(alunoId)) {
        return turma;
      }

      // Adicionar aluno à turma
      final newAlunos = [...turma.alunos, alunoId];
      await _firestore.collection('turmas').doc(turmaId).update({
        'alunos': newAlunos,
      });

      return turma.copyWith(alunos: newAlunos);
    } on TurmaNaoEncontradaException {
      rethrow;
    } catch (e) {
      throw ServerException('Erro ao adicionar aluno à turma: ${e.toString()}');
    }
  }

  @override
  Future<Turma> removerAlunoTurma(String turmaId, String alunoId) async {
    try {
      // Buscar turma atual
      final turmaDoc = await _firestore.collection('turmas').doc(turmaId).get();

      if (!turmaDoc.exists) {
        throw TurmaNaoEncontradaException('ID não encontrado');
      }

      final turma = Turma.fromFirestore(turmaDoc);

      // Remover aluno da turma
      final newAlunos = turma.alunos.where((id) => id != alunoId).toList();
      await _firestore.collection('turmas').doc(turmaId).update({
        'alunos': newAlunos,
      });

      return turma.copyWith(alunos: newAlunos);
    } on TurmaNaoEncontradaException {
      rethrow;
    } catch (e) {
      throw ServerException('Erro ao remover aluno da turma: ${e.toString()}');
    }
  }

  @override
  Future<Turma> adicionarAtividadeTurma(
      String turmaId, String atividadeId) async {
    try {
      // Buscar turma atual
      final turmaDoc = await _firestore.collection('turmas').doc(turmaId).get();

      if (!turmaDoc.exists) {
        throw TurmaNaoEncontradaException('ID não encontrado');
      }

      final turma = Turma.fromFirestore(turmaDoc);

      // Verificar se a atividade já está na turma
      if (turma.atividades.contains(atividadeId)) {
        return turma;
      }

      // Adicionar atividade à turma
      final newAtividades = [...turma.atividades, atividadeId];
      await _firestore.collection('turmas').doc(turmaId).update({
        'atividades': newAtividades,
      });

      return turma.copyWith(atividades: newAtividades);
    } on TurmaNaoEncontradaException {
      rethrow;
    } catch (e) {
      throw ServerException(
          'Erro ao adicionar atividade à turma: ${e.toString()}');
    }
  }

  @override
  Future<Turma> removerAtividadeTurma(
      String turmaId, String atividadeId) async {
    try {
      // Buscar turma atual
      final turmaDoc = await _firestore.collection('turmas').doc(turmaId).get();

      if (!turmaDoc.exists) {
        throw TurmaNaoEncontradaException('ID não encontrado');
      }

      final turma = Turma.fromFirestore(turmaDoc);

      // Remover atividade da turma
      final newAtividades =
          turma.atividades.where((id) => id != atividadeId).toList();
      await _firestore.collection('turmas').doc(turmaId).update({
        'atividades': newAtividades,
      });

      return turma.copyWith(atividades: newAtividades);
    } on TurmaNaoEncontradaException {
      rethrow;
    } catch (e) {
      throw ServerException(
          'Erro ao remover atividade da turma: ${e.toString()}');
    }
  }
}
