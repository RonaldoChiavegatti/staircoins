import 'package:flutter/material.dart';
import 'package:staircoins/screens/professor/cadastro_produto_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/produto_provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/models/produto.dart';

class ProfessorProdutosScreen extends StatefulWidget {
  const ProfessorProdutosScreen({super.key});

  @override
  State<ProfessorProdutosScreen> createState() =>
      _ProfessorProdutosScreenState();
}

class _ProfessorProdutosScreenState extends State<ProfessorProdutosScreen> {
  List<Produto> _produtosProfessor = [];
  bool _isLoading = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final produtoProvider =
          Provider.of<ProdutoProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Verificar se o usuário está autenticado e é professor
      if (!authProvider.isAuthenticated || !authProvider.isProfessor) {
        throw Exception('Usuário não autenticado ou não é professor');
      }

      final professorId = authProvider.user?.id;
      if (professorId == null) {
        throw Exception('ID do professor não encontrado');
      }

      // Recarregar todos os produtos
      await produtoProvider.carregarProdutos();

      // Filtrar apenas os produtos do professor atual
      _produtosProfessor = produtoProvider.produtos
          .where((produto) => produto.professorId == professorId)
          .toList();

      debugPrint(
          'ProfessorProdutosScreen: Total de ${_produtosProfessor.length} produtos encontrados para o professor $professorId');
    } catch (e) {
      _erro = e.toString();
      debugPrint('ProfessorProdutosScreen: Erro ao carregar produtos: $_erro');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_erro != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro ao carregar produtos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_erro!),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _carregarProdutos,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Barra de busca
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    // TODO: Implementar busca
                  },
                ),
              ),
              // Lista de produtos
              Expanded(
                child: _produtosProfessor.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.card_giftcard_outlined,
                              size: 64,
                              color: AppTheme.mutedForegroundColor,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Nenhum produto cadastrado',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Crie seu primeiro produto para começar',
                              style: TextStyle(
                                color: AppTheme.mutedForegroundColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CadastroProdutoScreen(),
                                  ),
                                ).then((_) => _carregarProdutos());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Criar Produto'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarProdutos,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _produtosProfessor.length,
                          itemBuilder: (context, index) {
                            final produto = _produtosProfessor[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagem
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      color: AppTheme.mutedColor,
                                      child: produto.imagem != null
                                          ? Image.asset(produto.imagem!,
                                              fit: BoxFit.cover)
                                          : const Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                size: 48,
                                                color: AppTheme
                                                    .mutedForegroundColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Informações
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                produto.nome,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${produto.preco} 🪙',
                                              style: const TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 12,
                                                color: AppTheme
                                                    .mutedForegroundColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Qtd: ${produto.quantidade}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme
                                                    .mutedForegroundColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Tooltip(
                                          message:
                                              'Turma: ${produto.turmaId ?? "Nenhuma"}',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.groups_outlined,
                                                  size: 12,
                                                  color: AppTheme
                                                      .mutedForegroundColor),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Turma: ${produto.turmaId != null ? "Vinculada" : "Nenhuma"}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme
                                                        .mutedForegroundColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CadastroProdutoScreen(
                                                              produto: produto),
                                                    ),
                                                  ).then((_) =>
                                                      _carregarProdutos());
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 0,
                                                  ),
                                                ),
                                                child: const Text('Editar'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroProdutoScreen(),
            ),
          ).then((_) => _carregarProdutos());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
