import 'package:flutter/material.dart';
import 'package:staircoins/screens/professor/cadastro_produto_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/produto_provider.dart';

class ProfessorProdutosScreen extends StatelessWidget {
  const ProfessorProdutosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final produtoProvider = Provider.of<ProdutoProvider>(context);
    final produtos = produtoProvider.produtos;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (produtoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (produtoProvider.erro != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar produtos',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(produtoProvider.erro!),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => produtoProvider.carregarProdutos(),
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
                child: produtos.isEmpty
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
                                ).then(
                                    (_) => produtoProvider.carregarProdutos());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Criar Produto'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: produtos.length,
                        itemBuilder: (context, index) {
                          final produto = produtos[index];
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
                                              color:
                                                  AppTheme.mutedForegroundColor,
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
                                      Text(
                                        'Qtd: ${produto.quantidade}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.mutedForegroundColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Peso/Tamanho: ${produto.pesoTamanho ?? '-'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.mutedForegroundColor,
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
                                                ).then((_) => produtoProvider
                                                    .carregarProdutos());
                                              },
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
            ],
          );
        },
      ),
    );
  }
}
