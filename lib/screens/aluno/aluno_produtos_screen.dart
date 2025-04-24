import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/theme/app_theme.dart';

class AlunoProdutosScreen extends StatefulWidget {
  const AlunoProdutosScreen({Key? key}) : super(key: key);

  @override
  State<AlunoProdutosScreen> createState() => _AlunoProdutosScreenState();
}

class _AlunoProdutosScreenState extends State<AlunoProdutosScreen> {
  final List<Map<String, dynamic>> produtos = [
    {
      'id': '1',
      'nome': 'Caneta personalizada',
      'descricao': 'Caneta com o logo da escola',
      'preco': 50,
      'imagem': Icons.edit,
    },
    {
      'id': '2',
      'nome': 'Caderno StairCoins',
      'descricao': 'Caderno exclusivo do programa',
      'preco': 100,
      'imagem': Icons.book,
    },
    {
      'id': '3',
      'nome': 'Mochila escolar',
      'descricao': 'Mochila resistente para seus livros',
      'preco': 300,
      'imagem': Icons.backpack,
    },
    {
      'id': '4',
      'nome': 'Vale lanche',
      'descricao': 'Vale um lanche na cantina',
      'preco': 80,
      'imagem': Icons.fastfood,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Padding(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${authProvider.user?.staircoins ?? 0} StairCoins',
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return _buildProdutoCard(produto);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
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
            child: Center(
              child: Icon(
                produto['imagem'] as IconData,
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
                  produto['nome'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  produto['descricao'] as String,
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
                          color: AppTheme.primaryColor, 
                          size: 16
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${produto['preco']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        _showComprarDialog(context, produto);
                      },
                      icon: const Icon(Icons.shopping_cart, 
                        color: AppTheme.primaryColor
                      ),
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

  void _showComprarDialog(BuildContext context, Map<String, dynamic> produto) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staircoins = authProvider.user?.staircoins ?? 0;
    final preco = produto['preco'] as int;
    final saldoSuficiente = staircoins >= preco;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comprar ${produto['nome']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preço: $preco StairCoins'),
            const SizedBox(height: 8),
            Text('Seu saldo: $staircoins StairCoins'),
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
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: saldoSuficiente
                ? () {
                    // Lógica para processar a compra
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${produto['nome']} comprado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Confirmar Compra'),
          ),
        ],
      ),
    );
  }
} 