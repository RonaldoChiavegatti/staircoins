import 'package:flutter/material.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/screens/aluno/atividade/detalhe_entrega_atividade_screen.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/entrega_atividade_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staircoins/models/entrega_atividade.dart'; // Importa o modelo EntregaAtividade

class DetalheAtividadeScreen extends StatelessWidget {
  final Atividade atividade;

  const DetalheAtividadeScreen({super.key, required this.atividade});

  // Função auxiliar para encontrar a entrega (igual à de aluno_atividades_screen)
  EntregaAtividade? _findEntrega(Atividade atividade, String? userId,
      EntregaAtividadeProvider entregaProvider) {
    if (userId == null) return null;
    for (final entrega in entregaProvider.entregas) {
      if (entrega.atividadeId == atividade.id && entrega.alunoId == userId) {
        return entrega;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final entregaProvider = Provider.of<EntregaAtividadeProvider>(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Usa a função auxiliar para encontrar a entrega
    final entrega = _findEntrega(atividade, userId, entregaProvider);

    // Garante que o status seja do tipo String para o switch
    final status =
        entrega?.status ?? atividade.status.toString().split('.').last;
    final nota = entrega?.nota;
    final feedback = entrega?.feedback;

    return Scaffold(
      appBar: AppBar(
        title: Text(atividade.titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                atividade.titulo,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusBadge(status),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${atividade.pontuacao} moedas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Entrega: ${DateFormat('dd/MM/yyyy HH:mm').format(atividade.dataEntrega)}',
                style: const TextStyle(
                  color: AppTheme.mutedForegroundColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Descrição:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                atividade.descricao,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (status == 'pendente' || status == 'atrasado')
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DetalheEntregaAtividadeScreen(atividade: atividade),
                      ),
                    );
                  },
                  child: const Text('Entregar Atividade'),
                ),
              if (status == 'entregue') ...[
                const SizedBox(height: 16),
                if (nota != null)
                  Text('Nota: $nota',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                if (feedback != null && feedback.isNotEmpty)
                  Text('Feedback: $feedback'),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Anexos screen
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mutedColor),
                child: const Text('Anexos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pendente':
        backgroundColor = AppTheme.warningColor.withOpacity(0.2);
        textColor = AppTheme.warningColor;
        label = 'Pendente';
        break;
      case 'entregue':
        backgroundColor = AppTheme.successColor.withOpacity(0.2);
        textColor = AppTheme.successColor;
        label = 'Entregue';
        break;
      case 'atrasado':
        backgroundColor = AppTheme.errorColor.withOpacity(0.2);
        textColor = AppTheme.errorColor;
        label = 'Atrasado';
        break;
      default:
        backgroundColor = AppTheme.mutedColor;
        textColor = AppTheme.mutedForegroundColor;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
