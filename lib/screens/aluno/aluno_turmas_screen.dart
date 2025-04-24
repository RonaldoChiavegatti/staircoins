import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/aluno/turma/detalhe_turma_aluno_screen.dart';
import 'package:staircoins/screens/aluno/turma/entrar_turma_screen.dart';
import 'package:staircoins/theme/app_theme.dart';

class AlunoTurmasScreen extends StatelessWidget {
  const AlunoTurmasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final minhasTurmas = turmaProvider.getMinhasTurmas();
    final isLoading = turmaProvider.isLoading;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de busca
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar turmas...',
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

                // Lista de turmas
                Expanded(
                  child: minhasTurmas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.groups_outlined,
                                size: 64,
                                color: AppTheme.mutedForegroundColor,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhuma turma encontrada',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Entre em uma turma para começar',
                                style: TextStyle(
                                  color: AppTheme.mutedForegroundColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const EntrarTurmaScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Entrar em uma Turma'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: minhasTurmas.length,
                          itemBuilder: (context, index) {
                            final turma = minhasTurmas[index];
                            return _buildTurmaCard(context, turma);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EntrarTurmaScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTurmaCard(BuildContext context, Turma turma) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetalheTurmaAlunoScreen(turmaId: turma.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                      turma.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.groups_outlined,
                    color: AppTheme.mutedForegroundColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                turma.descricao,
                style: const TextStyle(
                  color: AppTheme.mutedForegroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
