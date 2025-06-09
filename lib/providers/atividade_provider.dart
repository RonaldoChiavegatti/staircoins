import 'package:flutter/material.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:uuid/uuid.dart';

class AtividadeProvider with ChangeNotifier {
  List<Atividade> _atividades = [];
  bool _isLoading = false;

  List<Atividade> get atividades => _atividades;
  bool get isLoading => _isLoading;

  // Dados mockados para simulação
  final List<Map<String, dynamic>> _mockAtividades = [
    {
      'id': '1',
      'titulo': 'Trabalho de Matemática',
      'descricao':
          'Resolver os exercícios das páginas 45-48 do livro de matemática. Mostrar todos os cálculos e justificar as respostas.',
      'dataEntrega': '2023-05-15T00:00:00.000',
      'pontuacao': 50,
      'status': 'pendente',
      'turmaId': '1',
    },
    {
      'id': '2',
      'titulo': 'Redação sobre Meio Ambiente',
      'descricao':
          'Escrever uma redação de 20-30 linhas sobre a importância da preservação do meio ambiente, citando exemplos práticos de como podemos contribuir no dia a dia.',
      'dataEntrega': '2023-05-20T00:00:00.000',
      'pontuacao': 30,
      'status': 'pendente',
      'turmaId': '1',
    },
    {
      'id': '3',
      'titulo': 'Questionário de História',
      'descricao':
          'Responder ao questionário sobre a Revolução Industrial. Pesquisar em fontes confiáveis e citar as referências utilizadas.',
      'dataEntrega': '2023-05-10T00:00:00.000',
      'pontuacao': 20,
      'status': 'entregue',
      'turmaId': '2',
    },
    {
      'id': '4',
      'titulo': 'Apresentação de Ciências',
      'descricao':
          'Preparar uma apresentação sobre o sistema solar. Incluir informações sobre todos os planetas e pelo menos 3 curiosidades sobre o espaço.',
      'dataEntrega': '2023-04-30T00:00:00.000',
      'pontuacao': 40,
      'status': 'atrasado',
      'turmaId': '1',
    },
  ];

  AtividadeProvider() {
    _loadAtividades();
  }

  Future<void> _loadAtividades() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(milliseconds: 500));

      _atividades = _mockAtividades.map((a) => Atividade.fromJson(a)).toList();
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
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      final novaAtividade = Atividade(
        id: const Uuid().v4(),
        titulo: titulo,
        descricao: descricao,
        dataEntrega: dataEntrega,
        pontuacao: pontuacao,
        status: AtividadeStatus.pendente,
        turmaId: turmaId,
      );

      _atividades.add(novaAtividade);
      _mockAtividades.add(novaAtividade.toJson());

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
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      final index = _atividades.indexWhere((a) => a.id == atividadeId);
      if (index == -1) {
        throw Exception('Atividade não encontrada');
      }

      final atividade = _atividades[index];
      final updatedAtividade = atividade.copyWith(
        status: AtividadeStatus.entregue,
      );

      _atividades[index] = updatedAtividade;
      _mockAtividades[index] = updatedAtividade.toJson();

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

    // Recarregar as atividades após limpar
    _loadAtividades();
  }
}
