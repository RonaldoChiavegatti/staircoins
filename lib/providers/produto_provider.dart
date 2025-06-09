import 'package:flutter/material.dart';
import 'package:staircoins/models/produto.dart';
import 'package:uuid/uuid.dart';

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
      'descricao':
          'Caneta com o logo da escola, ideal para estudantes que buscam qualidade e estilo. A caneta possui tinta azul e ponta média, garantindo uma escrita suave e confortável.',
      'preco': 50,
      'quantidade': 20,
      'imagem': 'assets/images/caneta.png',
    },
    {
      'id': '2',
      'nome': 'Caderno Exclusivo',
      'descricao':
          'Caderno capa dura com 100 folhas, design exclusivo e papel de alta qualidade. Perfeito para anotações em sala de aula ou para organizar seus estudos em casa.',
      'preco': 150,
      'quantidade': 15,
      'imagem': 'assets/images/caderno.png',
    },
    {
      'id': '3',
      'nome': 'Adesivos',
      'descricao':
          'Conjunto com 10 adesivos temáticos da escola, perfeitos para personalizar seus materiais e mostrar seu espírito escolar. Adesivos resistentes à água e duráveis.',
      'preco': 30,
      'quantidade': 50,
      'imagem': 'assets/images/adesivos.png',
    },
    {
      'id': '4',
      'nome': 'Squeeze',
      'descricao':
          'Garrafa de água 500ml, material durável e livre de BPA. Design moderno com o logo da escola, perfeita para manter-se hidratado durante as aulas e atividades físicas.',
      'preco': 100,
      'quantidade': 25,
      'imagem': 'assets/images/squeeze.png',
    },
    {
      'id': '5',
      'nome': 'Mochila',
      'descricao':
          'Mochila resistente à água com compartimentos organizados, alças acolchoadas e espaço para laptop. Design exclusivo com o logo da escola, combinando estilo e funcionalidade.',
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
      codigo +=
          caracteres[DateTime.now().millisecondsSinceEpoch % caracteres.length];
    }

    return codigo;
  }

  // Método para limpar os dados quando o usuário fizer logout
  void limparDados() {
    debugPrint('ProdutoProvider: Limpando dados após logout');
    _produtos = [];
    _isLoading = false;
    notifyListeners();
    debugPrint('ProdutoProvider: Dados limpos com sucesso');

    // Recarregar os produtos após limpar
    _loadProdutos();
  }
}
