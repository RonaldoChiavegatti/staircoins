import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/entrega_atividade_provider.dart';
import 'package:staircoins/models/entrega_atividade.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:url_launcher/url_launcher.dart';

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

              // Nota original antes da atualização
              final double? notaOriginal = entrega.nota;

              final updated = entrega.copyWith(nota: nota, feedback: feedback);
              await provider.atualizarEntrega(updated);

              // Calcular e atribuir StairCoins
              if (nota != null && nota >= 0) {
                final int pontuacaoAtividade = widget.atividade.pontuacao;

                // 1. Reverter StairCoins da nota anterior, se houver
                if (notaOriginal != null && notaOriginal >= 0) {
                  final int staircoinsRevertidos =
                      (pontuacaoAtividade * (notaOriginal / 10.0)).round();
                  if (staircoinsRevertidos > 0) {
                    await provider.adicionarStaircoinsAoAluno(
                        entrega.alunoId, -staircoinsRevertidos);
                    debugPrint(
                        'StairCoins revertidos: ${staircoinsRevertidos}');
                  }
                }

                // 2. Atribuir StairCoins da nova nota
                final int staircoinsGanhos =
                    (pontuacaoAtividade * (nota / 10.0)).round();

                if (staircoinsGanhos > 0) {
                  await provider.adicionarStaircoinsAoAluno(
                      entrega.alunoId, staircoinsGanhos);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${staircoinsGanhos} StairCoins atribuídos ao aluno!')),
                  );
                }
              }

              // Recarregar as entregas para atualizar a UI
              await provider.fetchEntregasByAtividade(widget.atividade.id);

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

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Não foi possível abrir o link $url';
    }
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
              final aluno = provider.alunosCache[entrega.alunoId];
              final String alunoName = aluno?.name ?? 'Aluno Desconhecido';

              // Determine file type and icon
              Widget leadingWidget;
              String fileExtension = '';

              if (entrega.anexoUrl != null && entrega.anexoUrl!.isNotEmpty) {
                final uri = Uri.parse(entrega.anexoUrl!);
                // Remove query parameters before getting the extension
                String pathWithoutQuery = uri.path.split('?').first;
                fileExtension = pathWithoutQuery.split('.').last.toLowerCase();

                if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
                    .contains(fileExtension)) {
                  leadingWidget = GestureDetector(
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
                  );
                } else {
                  // For non-image files, show a generic file icon
                  leadingWidget = const Icon(Icons.insert_drive_file);
                }
              } else {
                leadingWidget = const Icon(Icons.person);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: SizedBox(
                    width: 48,
                    child: leadingWidget,
                  ),
                  title: Text('Aluno: $alunoName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${entrega.status}'),
                      if (entrega.nota != null) Text('Nota: ${entrega.nota}'),
                      if (entrega.feedback != null &&
                          entrega.feedback!.isNotEmpty)
                        Text('Feedback: ${entrega.feedback}'),
                      if (entrega.anexoUrl != null &&
                          entrega.anexoUrl!.isNotEmpty)
                        Text('Tipo de arquivo: '
                            '${entrega.originalFileName != null && entrega.originalFileName!.isNotEmpty ? entrega.originalFileName!.split('.').last.toUpperCase() : fileExtension.toUpperCase()}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entrega.anexoUrl != null &&
                          entrega.anexoUrl!.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.download_for_offline),
                          onPressed: () => _launchURL(entrega.anexoUrl!),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _atribuirNotaDialog(context, entrega),
                      ),
                    ],
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
