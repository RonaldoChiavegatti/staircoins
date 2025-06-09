import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/produto_provider.dart';
import 'package:staircoins/models/troca_produto.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/theme/app_theme.dart';

class AlunoHistoricoTrocasScreen extends StatefulWidget {
  const AlunoHistoricoTrocasScreen({super.key});

  @override
  State<AlunoHistoricoTrocasScreen> createState() =>
      _AlunoHistoricoTrocasScreenState();
}

class _AlunoHistoricoTrocasScreenState
    extends State<AlunoHistoricoTrocasScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final produtoProvider =
        Provider.of<ProdutoProvider>(context, listen: false);
    if (authProvider.user != null) {
      produtoProvider.carregarTrocasAluno(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtoProvider = Provider.of<ProdutoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final trocas = produtoProvider.trocas;
    final produtos = {for (var p in produtoProvider.produtos) p.id: p};

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Trocas')),
      body: produtoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : trocas.isEmpty
              ? const Center(child: Text('Nenhuma troca realizada.'))
              : ListView.separated(
                  itemCount: trocas.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final troca = trocas[index];
                    final produto = produtos[troca.produtoId];
                    return ListTile(
                      leading: produto?.imagem != null
                          ? Image.asset(produto!.imagem!, width: 48, height: 48)
                          : const Icon(Icons.card_giftcard, size: 40),
                      title: Text(produto?.nome ?? 'Produto removido'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Código: ${troca.codigoTroca}'),
                          Text(
                              'Data: ${troca.data.day}/${troca.data.month}/${troca.data.year}'),
                          Text('Status: ${troca.status}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
