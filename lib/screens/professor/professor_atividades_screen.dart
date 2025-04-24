import 'package:flutter/material.dart';
import 'package:staircoins/theme/app_theme.dart';

class ProfessorAtividadesScreen extends StatelessWidget {
  const ProfessorAtividadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados mockados para demonstração
    final atividades = [
      {
        'id': '1',
        'titulo': 'Trabalho de Matemática',
        'dataEntrega': '2023-05-15',
        'pontuacao': 50,
        'status': 'ativa',
        'turma': 'Matemática - 9º Ano',
      },
      {
        'id': '2',
        'titulo': 'Redação sobre Meio Ambiente',
        'dataEntrega': '2023-05-20',
        'pontuacao': 30,
        'status': 'ativa',
        'turma': 'Matemática - 9º Ano',
      },
      {
        'id': '3',
        'titulo': 'Questionário de História',
        'dataEntrega': '2023-05-10',
        'pontuacao': 20,
        'status': 'encerrada',
        'turma': 'História - 8º Ano',
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
                hintText: 'Buscar atividades...',
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

          // Lista de atividades
          Expanded(
            child: atividades.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppTheme.mutedForegroundColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhuma atividade encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crie sua primeira atividade para começar',
                          style: TextStyle(
                            color: AppTheme.mutedForegroundColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar criação de atividade
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Criar Atividade'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: atividades.length,
                    itemBuilder: (context, index) {
                      final atividade = atividades[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      atividade['titulo'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: atividade['status'] == 'ativa'
                                          ? AppTheme.successColor.withOpacity(0.2)
                                          : AppTheme.mutedColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      atividade['status'] == 'ativa' ? 'Ativa' : 'Encerrada',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: atividade['status'] == 'ativa'
                                            ? AppTheme.successColor
                                            : AppTheme.mutedForegroundColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Entrega: ${atividade['dataEntrega']}',
                                style: const TextStyle(
                                  color: AppTheme.mutedForegroundColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
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
                                          '${atividade['pontuacao']} moedas',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Turma: ${atividade['turma']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.mutedForegroundColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implementar detalhes da atividade
                                    },
                                    child: const Text('Ver'),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
