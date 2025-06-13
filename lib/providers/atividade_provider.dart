import 'package:flutter/material.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AtividadeProvider with ChangeNotifier {
  List<Atividade> _atividades = [];
  bool _isLoading = false;

  List<Atividade> get atividades => _atividades;
  bool get isLoading => _isLoading;

  AtividadeProvider() {
    _loadAtividades();
  }

  Future<void> _loadAtividades() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('atividades').get();
      _atividades = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Atividade.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao carregar atividades: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Atividade> getAtividadesByTurma(String turmaId) {
    return _atividades.where((a) => a.turmaId == turmaId).toList();
  }

  Atividade? getAtividadeById(String id) {
    try {
      return _atividades.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> criarAtividade({
    required String titulo,
    required String descricao,
    required DateTime dataEntrega,
    required int pontuacao,
    required String turmaId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = FirebaseFirestore.instance.collection('atividades').doc();
      final novaAtividade = Atividade(
        id: docRef.id,
        titulo: titulo,
        descricao: descricao,
        dataEntrega: dataEntrega,
        pontuacao: pontuacao,
        status: AtividadeStatus.pendente,
        turmaId: turmaId,
      );

      await docRef.set(novaAtividade.toJson());

      _atividades.add(novaAtividade);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> entregarAtividade(String atividadeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef =
          FirebaseFirestore.instance.collection('atividades').doc(atividadeId);
      await docRef.update({
        'status': AtividadeStatus.entregue.toString(),
      });

      final index = _atividades.indexWhere((a) => a.id == atividadeId);
      if (index != -1) {
        final atividade = _atividades[index];
        final updatedAtividade = atividade.copyWith(
          status: AtividadeStatus.entregue,
        );
        _atividades[index] = updatedAtividade;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpar os dados quando o usuário fizer logout
  void limparDados() {
    debugPrint('AtividadeProvider: Limpando dados após logout');
    _atividades = [];
    _isLoading = false;
    notifyListeners();
    debugPrint('AtividadeProvider: Dados limpos com sucesso');
  }

  Future<void> fetchAtividadesByTurma(String turmaId) async {
    _isLoading = true;
    _atividades = [];
    notifyListeners();

    debugPrint('AtividadeProvider: Buscando atividades para turma $turmaId');

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('atividades')
          .where('turmaId', isEqualTo: turmaId)
          .get();

      debugPrint(
          'AtividadeProvider: Encontradas ${snapshot.docs.length} atividades');

      _atividades = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Atividade.fromJson(data);
      }).toList();

      // Ordena as atividades por data de entrega (mais próximas primeiro)
      _atividades.sort((a, b) => a.dataEntrega.compareTo(b.dataEntrega));

      debugPrint('AtividadeProvider: Atividades carregadas com sucesso');
    } catch (e) {
      debugPrint('Erro ao buscar atividades do Firestore: $e');
      _atividades = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
