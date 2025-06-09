import 'package:flutter/material.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/models/troca_produto.dart';
import 'package:staircoins/domain/repositories/produto_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:staircoins/providers/auth_provider.dart';

class ProdutoProvider with ChangeNotifier {
  final ProdutoRepository repository;
  ProdutoProvider(this.repository) {
    carregarProdutos();
  }

  List<Produto> _produtos = [];
  bool _isLoading = false;
  List<TrocaProduto> _trocas = [];
  String? _erro;

  List<Produto> get produtos => _produtos;
  bool get isLoading => _isLoading;
  List<TrocaProduto> get trocas => _trocas;
  String? get erro => _erro;

  // Dados mockados para simulação

  Future<void> carregarProdutos() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    final result = await repository.getProdutos();
    result.fold(
      (erro) {
        _produtos = [];
        _erro = erro.toString();
      },
      (lista) {
        _produtos = lista;
        _erro = null;
      },
    );
    _isLoading = false;
    notifyListeners();
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
    String? pesoTamanho,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    final produto = Produto(
      id: const Uuid().v4(),
      nome: nome,
      descricao: descricao,
      preco: preco,
      quantidade: quantidade,
      imagem: imagem,
      pesoTamanho: pesoTamanho,
    );
    final result = await repository.adicionarProduto(produto);
    result.fold((erro) {
      _erro = erro.toString();
    }, (_) {
      _erro = null;
      carregarProdutos();
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> editarProduto(Produto produto) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    final result = await repository.editarProduto(produto);
    result.fold((erro) {
      _erro = erro.toString();
    }, (_) {
      _erro = null;
      carregarProdutos();
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> removerProduto(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    final result = await repository.removerProduto(id);
    result.fold((erro) {
      _erro = erro.toString();
    }, (_) {
      _erro = null;
      carregarProdutos();
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> trocarProduto({
    required String produtoId,
    required String alunoId,
    required int moedasAluno,
    AuthProvider? authProvider,
  }) async {
    _isLoading = true;
    notifyListeners();
    final produto = getProdutoById(produtoId);
    if (produto == null) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
    if (moedasAluno < produto.preco) {
      _isLoading = false;
      notifyListeners();
      return 'MOEDAS_INSUFICIENTES';
    }
    final result =
        await repository.trocarProduto(produtoId: produtoId, alunoId: alunoId);
    String? codigo;
    result.fold((erro) => codigo = null, (c) => codigo = c);
    if (codigo != null && authProvider != null) {
      await authProvider.reloadUserFromFirebase();
    }
    _isLoading = false;
    notifyListeners();
    return codigo;
  }

  Future<void> carregarTrocasAluno(String alunoId) async {
    _isLoading = true;
    notifyListeners();
    final result = await repository.getTrocasByAluno(alunoId);
    result.fold((erro) => _trocas = [], (lista) => _trocas = lista);
    _isLoading = false;
    notifyListeners();
  }

  void limparDados() {
    _produtos = [];
    _trocas = [];
    _isLoading = false;
    notifyListeners();
  }
}
