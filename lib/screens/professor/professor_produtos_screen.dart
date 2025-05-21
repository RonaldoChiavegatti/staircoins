import 'package:flutter/material.dart';
import 'package:staircoins/screens/professor/cadastro_produto_screen.dart';
import 'package:staircoins/theme/app_theme.dart';

class ProfessorProdutosScreen extends StatelessWidget {
  const ProfessorProdutosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados mockados para demonstração
    final produtos = [
      {
        'id': '1',
        'nome': 'Caneta Personalizada',
        'descricao': 'Caneta com o logo da escola',
        'preco': 50,
        'quantidade': 20,
        'imagem': 'assets/images/caneta.png',
      },
      {
        'id': '2',
        'nome': 'Caderno Exclusivo',
        'descricao': 'Caderno capa dura com 100 folhas',
        'preco': 150,
        'quantidade': 15,
        'imagem': 'assets/images/caderno.png',
      },
      {
        'id': '3',
        'nome': 'Adesivos',
        'descricao': 'Conjunto com 10 adesivos',
        'preco': 30,
        'quantidade': 50,
        'imagem': 'assets/images/adesivos.png',
      },
    ];

    return Scaffold(
      body: Column(
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
                          'Nenhum produto encontrado',
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
                                builder: (context) => const CadastroProdutoScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Criar Produto'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: AppTheme.mutedForegroundColor,
                                  ),
                                ),
                              ),
                            ),

                            // Informações
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          produto['nome'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${produto['preco']} 🪙',
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qtd: ${produto['quantidade']}',
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
                                            // TODO: Implementar edição de produto
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
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
      ),
    );
  }
}
