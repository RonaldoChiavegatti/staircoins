import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/providers/produto_provider.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/screens/aluno/aluno_historico_trocas_screen.dart';

class AlunoProdutosScreen extends StatefulWidget {
  const AlunoProdutosScreen({super.key});

  @override
  State<AlunoProdutosScreen> createState() => _AlunoProdutosScreenState();
}

class _AlunoProdutosScreenState extends State<AlunoProdutosScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final produtoProvider = Provider.of<ProdutoProvider>(context);
    final produtos =
        produtoProvider.produtos.where((p) => p.quantidade > 0).toList();
    final user = authProvider.user;
    final moedas = user?.staircoins ?? 0;
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
            Text('Erro ao carregar produtos',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    return Stack(
      children: [
        produtos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.card_giftcard_outlined,
                        size: 64, color: AppTheme.mutedForegroundColor),
                    const SizedBox(height: 16),
                    const Text('Nenhum produto disponível',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Aguarde, em breve novos produtos!',
                        style: TextStyle(color: AppTheme.mutedForegroundColor)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => produtoProvider.carregarProdutos(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Atualizar'),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Catálogo de Produtos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${user?.staircoins ?? 0} StairCoins',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: produtos.length,
                        itemBuilder: (context, index) {
                          final produto = produtos[index];
                          return _buildProdutoCard(
                              context, produto, moedas, user?.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'historicoTrocas',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AlunoHistoricoTrocasScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('Minhas Trocas'),
          ),
        ),
      ],
    );
  }

  Widget _buildProdutoCard(
      BuildContext context, Produto produto, int moedas, String? alunoId) {
    final esgotado = produto.quantidade == 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: produto.imagem != null
                ? Image.asset(produto.imagem!, fit: BoxFit.cover)
                : Center(
                    child: Icon(
                      Icons.card_giftcard,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  produto.descricao,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: AppTheme.primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${produto.preco}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    esgotado
                        ? const Text('Esgotado',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold))
                        : IconButton(
                            onPressed: () {
                              _showComprarDialog(
                                  context, produto, moedas, alunoId);
                            },
                            icon: const Icon(Icons.shopping_cart,
                                color: AppTheme.primaryColor),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComprarDialog(BuildContext context, Produto produto, int moedas,
      String? alunoId) async {
    final scaffoldContext = context;
    final saldoSuficiente = moedas >= produto.preco;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comprar ${produto.nome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preço: ${produto.preco} StairCoins'),
            const SizedBox(height: 8),
            Text('Seu saldo: $moedas StairCoins'),
            if (!saldoSuficiente) ...[
              const SizedBox(height: 12),
              const Text(
                'Saldo insuficiente para realizar esta compra.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: saldoSuficiente
                ? () async {
                    if (alunoId == null) return;
                    final produtoProvider = Provider.of<ProdutoProvider>(
                        scaffoldContext,
                        listen: false);
                    final authProvider = Provider.of<AuthProvider>(
                        scaffoldContext,
                        listen: false);
                    final codigo = await produtoProvider.trocarProduto(
                      produtoId: produto.id,
                      alunoId: alunoId,
                      moedasAluno: moedas,
                      authProvider: authProvider,
                    );
                    Navigator.of(ctx).pop();
                    if (codigo == 'MOEDAS_INSUFICIENTES') {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text('Moedas insuficientes!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (codigo != null) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text('Troca realizada! Código: $codigo'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao realizar troca.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                : null,
            child: const Text('Confirmar Compra'),
          ),
        ],
      ),
    );
  }
}
