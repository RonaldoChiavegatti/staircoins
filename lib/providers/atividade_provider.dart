import 'package:flutter/material.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:uuid/uuid.dart';
import "package:staircoins/models/produto.dart";

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
      'descricao': 'Resolver os exercícios das páginas 45-48 do livro de matemática. Mostrar todos os cálculos e justificar as respostas.',
      'dataEntrega': '2023-05-15T00:00:00.000',
      'pontuacao': 50,
      'status': 'pendente',
      'turmaId': '1',
    },
    {
      'id': '2',
      'titulo': 'Redação sobre Meio Ambiente',
      'descricao': 'Escrever uma redação de 20-30 linhas sobre a importância da preservação do meio ambiente, citando exemplos práticos de como podemos contribuir no dia a dia.',
      'dataEntrega': '2023-05-20T00:00:00.000',
      'pontuacao': 30,
      'status': 'pendente',
      'turmaId': '1',
    },
    {
      'id': '3',
      'titulo': 'Questionário de História',
      'descricao': 'Responder ao questionário sobre a Revolução Industrial. Pesquisar em fontes confiáveis e citar as referências utilizadas.',
      'dataEntrega': '2023-05-10T00:00:00.000',
      'pontuacao': 20,
      'status': 'entregue',
      'turmaId': '2',
    },
    {
      'id': '4',
      'titulo': 'Apresentação de Ciências',
      'descricao': 'Preparar uma apresentação sobre o sistema solar. Incluir informações sobre todos os planetas e pelo menos 3 curiosidades sobre o espaço.',
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
}


class ProdutoProvider with ChangeNotifier {
  List<Produto> _produtos = [];
  bool _isLoading = false;

  List<Produto> get produtos => _produtos;
  bool get isLoading => _isLoading;

  // Dados mockados para simulação
  final List<Map<String, dynamic>> _mockProdutos = [
    {
      'id': '1',
      'nome': 'Caneta Personalizada',
      'descricao': 'Caneta com o logo da escola, ideal para estudantes que buscam qualidade e estilo. A caneta possui tinta azul e ponta média, garantindo uma escrita suave e confortável.',
      'preco': 50,
      'quantidade': 20,
      'imagem': 'assets/images/caneta.png',
    },
    {
      'id': '2',
      'nome': 'Caderno Exclusivo',
      'descricao': 'Caderno capa dura com 100 folhas, design exclusivo e papel de alta qualidade. Perfeito para anotações em sala de aula ou para organizar seus estudos em casa.',
      'preco': 150,
      'quantidade': 15,
      'imagem': 'assets/images/caderno.png',
    },
    {
      'id': '3',
      'nome': 'Adesivos',
      'descricao': 'Conjunto com 10 adesivos temáticos da escola, perfeitos para personalizar seus materiais e mostrar seu espírito escolar. Adesivos resistentes à água e duráveis.',
      'preco': 30,
      'quantidade': 50,
      'imagem': 'assets/images/adesivos.png',
    },
    {
      'id': '4',
      'nome': 'Squeeze',
      'descricao': 'Garrafa de água 500ml, material durável e livre de BPA. Design moderno com o logo da escola, perfeita para manter-se hidratado durante as aulas e atividades físicas.',
      'preco': 100,
      'quantidade': 25,
      'imagem': 'assets/images/squeeze.png',
    },
    {
      'id': '5',
      'nome': 'Mochila',
      'descricao': 'Mochila resistente à água com compartimentos organizados, alças acolchoadas e espaço para laptop. Design exclusivo com o logo da escola, combinando estilo e funcionalidade.',
      'preco': 300,
      'quantidade': 10,
      'imagem': 'assets/images/mochila.png',
    },
  ];

  ProdutoProvider() {
    _loadProdutos();
  }

  Future<void> _loadProdutos() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(milliseconds: 500));

      _produtos = _mockProdutos.map((p) => Produto.fromJson(p)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Produto? getProdutoById(String id) {
    try {
      return _produtos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> adicionarProduto({
    required String nome,
    required String descricao,
    required int preco,
    required int quantidade,
    String? imagem,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      final novoProduto = Produto(
        id: const Uuid().v4(),
        nome: nome,
        descricao: descricao,
        preco: preco,
        quantidade: quantidade,
        imagem: imagem,
      );

      _produtos.add(novoProduto);
      _mockProdutos.add(novoProduto.toJson());

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> trocarProduto(String produtoId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando delay de rede
      await Future.delayed(const Duration(seconds: 1));

      final index = _produtos.indexWhere((p) => p.id == produtoId);
      if (index == -1) {
        throw Exception('Produto não encontrado');
      }

      final produto = _produtos[index];
      final updatedProduto = produto.copyWith(
        quantidade: produto.quantidade - 1,
      );

      _produtos[index] = updatedProduto;
      _mockProdutos[index] = updatedProduto.toJson();

      // Gera código de troca
      final codigo = _gerarCodigoTroca();

      notifyListeners();
      return codigo;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _gerarCodigoTroca() {
    const prefixo = "STC";
    const caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var codigo = "$prefixo-";

    for (var i = 0; i < 6; i++) {
      codigo += caracteres[DateTime.now().millisecondsSinceEpoch % caracteres.length];
    }

    return codigo;
  }
}
