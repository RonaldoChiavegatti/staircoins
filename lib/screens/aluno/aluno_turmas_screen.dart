import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/aluno/turma/detalhe_turma_aluno_screen.dart';
import 'package:staircoins/screens/aluno/turma/entrar_turma_screen.dart';
import 'package:staircoins/theme/app_theme.dart';

class AlunoTurmasScreen extends StatefulWidget {
  const AlunoTurmasScreen({super.key});

  @override
  State<AlunoTurmasScreen> createState() => _AlunoTurmasScreenState();
}

class _AlunoTurmasScreenState extends State<AlunoTurmasScreen> {
  @override
  void initState() {
    super.initState();
    // Recarregar turmas quando a tela for exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTurmas();
    });
  }

  Future<void> _carregarTurmas() async {
    debugPrint('AlunoTurmasScreen: Recarregando turmas...');
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      final user = authProvider.user;

      if (user != null && user.turmas.isNotEmpty) {
        debugPrint(
            'AlunoTurmasScreen: Aluno tem ${user.turmas.length} turmas associadas: ${user.turmas}');

        // Primeiro recarregar todas as turmas
        await turmaProvider.recarregarTurmas();

        // Depois buscar especificamente as turmas do usuário
        await turmaProvider.buscarTurmasPorIds(user.turmas);

        // Verificar se as turmas foram carregadas corretamente
        final turmasCarregadas = turmaProvider.getTurmasAluno();
        debugPrint(
            'AlunoTurmasScreen: Turmas carregadas: ${turmasCarregadas.length}');

        // Se não carregou todas as turmas, usar o método de atualização forçada
        if (turmasCarregadas.length < user.turmas.length) {
          debugPrint(
              'AlunoTurmasScreen: Faltam turmas, iniciando atualização forçada');
          await turmaProvider.forcarAtualizacaoTurmasAluno();
        }
      } else {
        debugPrint(
            'AlunoTurmasScreen: Aluno não tem turmas associadas, recarregando todas');
        await turmaProvider.recarregarTurmas();
      }

      // Verificar as turmas carregadas
      final turmasAluno = turmaProvider.getTurmasAluno();
      debugPrint('AlunoTurmasScreen: Turmas carregadas: ${turmasAluno.length}');
      for (var turma in turmasAluno) {
        debugPrint(
            'AlunoTurmasScreen: Turma: ${turma.id} - ${turma.nome} - ${turma.codigo}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final minhasTurmas = turmaProvider.getTurmasAluno();
    final isLoading = turmaProvider.isLoading;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _carregarTurmas,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Barra de busca e botões
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: ${minhasTurmas.length} turmas',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _carregarTurmas,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Atualizar'),
                            ),
                          ],
                        ),
                      ],
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
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const EntrarTurmaScreen(),
                                      ),
                                    )
                                        .then((result) {
                                      // Recarregar turmas quando retornar da tela de entrar em turma
                                      if (result == true) {
                                        debugPrint(
                                            'AlunoTurmasScreen: Retornou da tela de entrar em turma com sucesso');
                                      }
                                      _carregarTurmas();
                                    });
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (_) => const EntrarTurmaScreen(),
            ),
          )
              .then((result) {
            // Recarregar turmas quando retornar da tela de entrar em turma
            if (result == true) {
              debugPrint(
                  'AlunoTurmasScreen: Retornou da tela de entrar em turma com sucesso');
            }
            _carregarTurmas();
          });
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
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => DetalheTurmaAlunoScreen(turmaId: turma.id),
                ),
              )
              .then((_) => _carregarTurmas());
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
                      turma.codigo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppTheme.mutedForegroundColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Professor: ${turma.professorId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
