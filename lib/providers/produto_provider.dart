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
    required String professorId,
    required String turmaId,
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
      professorId: professorId,
      turmaId: turmaId,
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

  // Método para buscar produtos por turmas específicas
  Future<List<Produto>> buscarProdutosPorTurmas(List<String> turmasIds,
      {List<String> professoresIds = const []}) async {
    // Verificar se já temos produtos carregados
    if (_produtos.isEmpty) {
      await carregarProdutos();
    }

    debugPrint('ProdutoProvider: Buscando produtos para turmas: $turmasIds');
    if (professoresIds.isNotEmpty) {
      debugPrint('ProdutoProvider: Filtrando por professores: $professoresIds');
    } else {
      debugPrint('ProdutoProvider: ATENÇÃO! Lista de professores vazia!');
    }
    debugPrint(
        'ProdutoProvider: Total de produtos carregados: ${_produtos.length}');

    List<Produto> produtosFiltrados = [];

    try {
      // Se não temos IDs de professores, usamos apenas as turmas
      if (professoresIds.isEmpty) {
        debugPrint(
            'ProdutoProvider: Sem IDs de professores, filtrando apenas por turmas');
        // Primeiro tenta buscar pelo repositório
        final result = await repository.getProdutosPorTurmas(turmasIds);
        result.fold(
          (erro) {
            debugPrint('ProdutoProvider: Erro na busca por turmas: $erro');
            // Em caso de erro, vamos usar a filtragem manual
            produtosFiltrados = _filtrarApenasPorTurmas(turmasIds);
          },
          (produtos) {
            produtosFiltrados = produtos;
          },
        );
      } else {
        // Temos IDs de professores, usamos ambos os filtros
        debugPrint('ProdutoProvider: Filtrando por turmas E professores');
        final result = await repository.getProdutosPorTurmas(turmasIds,
            professoresIds: professoresIds);
        result.fold(
          (erro) {
            debugPrint(
                'ProdutoProvider: Erro na busca por turmas e professores: $erro');
            // Em caso de erro, vamos usar a filtragem manual
            produtosFiltrados =
                _filtrarPorTurmasEProfessores(turmasIds, professoresIds);
          },
          (produtos) {
            produtosFiltrados = produtos;
          },
        );
      }
    } catch (e) {
      debugPrint('ProdutoProvider: Exceção ao buscar produtos: $e');
      // Em caso de exceção, fazemos filtragem manual
      if (professoresIds.isEmpty) {
        produtosFiltrados = _filtrarApenasPorTurmas(turmasIds);
      } else {
        produtosFiltrados =
            _filtrarPorTurmasEProfessores(turmasIds, professoresIds);
      }
    }

    // Garantir que produtos têm quantidade > 0
    produtosFiltrados =
        produtosFiltrados.where((p) => p.quantidade > 0).toList();

    debugPrint(
        'ProdutoProvider: Retornando ${produtosFiltrados.length} produtos filtrados');

    return produtosFiltrados;
  }

  // Método auxiliar para filtrar apenas por turmas (sem professores)
  List<Produto> _filtrarApenasPorTurmas(List<String> turmasIds) {
    debugPrint('ProdutoProvider: Filtrando manualmente apenas por turmas');
    final produtos = _produtos
        .where((produto) =>
            produto.quantidade > 0 &&
            produto.turmaId != null &&
            turmasIds.contains(produto.turmaId))
        .toList();

    debugPrint(
        'ProdutoProvider: ${produtos.length} produtos encontrados pelo filtro de turmas');
    return produtos;
  }

  // Método auxiliar para filtrar por turmas E professores
  List<Produto> _filtrarPorTurmasEProfessores(
      List<String> turmasIds, List<String> professoresIds) {
    debugPrint(
        'ProdutoProvider: Filtrando manualmente por turmas E professores');

    // Filtrar produtos:
    // 1. É de uma turma do aluno OU
    // 2. Foi criado por um professor das turmas do aluno
    final produtos = _produtos.where((produto) {
      final porTurma =
          produto.turmaId != null && turmasIds.contains(produto.turmaId);
      final porProfessor = produto.professorId != null &&
          professoresIds.contains(produto.professorId);

      return produto.quantidade > 0 && (porTurma || porProfessor);
    }).toList();

    debugPrint(
        'ProdutoProvider: ${produtos.length} produtos encontrados pelo filtro de turmas e professores');
    return produtos;
  }

  void limparDados() {
    _produtos = [];
    _trocas = [];
    _isLoading = false;
    notifyListeners();
  }
}
