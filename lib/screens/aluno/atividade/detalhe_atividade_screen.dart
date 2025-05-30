import 'package:flutter/material.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/screens/aluno/atividade/detalhe_entrega_atividade_screen.dart';

class DetalheAtividadeScreen extends StatelessWidget {
  final Atividade atividade;

  const DetalheAtividadeScreen({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
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
                  _buildStatusBadge(atividade.status),
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
              if (atividade.status == AtividadeStatus.pendente ||
                  atividade.status == AtividadeStatus.atrasado)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetalheEntregaAtividadeScreen(atividade: atividade),
                      ),
                    );
                  },
                  child: const Text('Entregar Atividade'),
              ),
              // TODO: Add submission form or button based on status
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: () {
 // TODO: Navigate to Anexos screen
 },
 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.mutedColor),
 child: const Text('Anexos'),
 ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AtividadeStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case AtividadeStatus.pendente:
        backgroundColor = AppTheme.warningColor.withOpacity(0.2);
        textColor = AppTheme.warningColor;
        label = 'Pendente';
        break;
      case AtividadeStatus.entregue:
        backgroundColor = AppTheme.successColor.withOpacity(0.2);
        textColor = AppTheme.successColor;
        label = 'Entregue';
        break;
      case AtividadeStatus.atrasado:
        backgroundColor = AppTheme.errorColor.withOpacity(0.2);
        textColor = AppTheme.errorColor;
        label = 'Atrasado';
        break;
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