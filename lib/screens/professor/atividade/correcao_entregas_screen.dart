import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/entrega_atividade_provider.dart';
import 'package:staircoins/models/entrega_atividade.dart';
import 'package:staircoins/models/atividade.dart';

class CorrecaoEntregasScreen extends StatefulWidget {
  final Atividade atividade;
  const CorrecaoEntregasScreen({Key? key, required this.atividade})
      : super(key: key);

  @override
  State<CorrecaoEntregasScreen> createState() => _CorrecaoEntregasScreenState();
}

class _CorrecaoEntregasScreenState extends State<CorrecaoEntregasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EntregaAtividadeProvider>(context, listen: false)
          .fetchEntregasByAtividade(widget.atividade.id);
    });
  }

  void _atribuirNotaDialog(BuildContext context, EntregaAtividade entrega) {
    final _notaController =
        TextEditingController(text: entrega.nota?.toString() ?? '');
    final _feedbackController =
        TextEditingController(text: entrega.feedback ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atribuir Nota e Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _notaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nota'),
            ),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(labelText: 'Feedback'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<EntregaAtividadeProvider>(context, listen: false);
              final nota = double.tryParse(_notaController.text);
              final feedback = _feedbackController.text;
              final updated = entrega.copyWith(nota: nota, feedback: feedback);
              await provider.atualizarEntrega(updated);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota e feedback atribuídos!')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entregas - ${widget.atividade.titulo}')),
      body: Consumer<EntregaAtividadeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.entregas.isEmpty) {
            return const Center(child: Text('Nenhuma entrega encontrada.'));
          }
          return ListView.builder(
            itemCount: provider.entregas.length,
            itemBuilder: (context, index) {
              final entrega = provider.entregas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: entrega.anexoUrl != null
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: Image.network(entrega.anexoUrl!),
                              ),
                            );
                          },
                          child: Image.network(entrega.anexoUrl!,
                              width: 48, height: 48, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.person),
                  title: Text('Aluno: ${entrega.alunoId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${entrega.status}'),
                      if (entrega.nota != null) Text('Nota: ${entrega.nota}'),
                      if (entrega.feedback != null &&
                          entrega.feedback!.isNotEmpty)
                        Text('Feedback: ${entrega.feedback}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _atribuirNotaDialog(context, entrega),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
