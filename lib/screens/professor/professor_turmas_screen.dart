import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/professor/aluno/cadastro_aluno_screen.dart';
import 'package:staircoins/screens/professor/turma/detalhe_turma_screen.dart';
import 'package:staircoins/screens/professor/turma/nova_turma_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/providers/auth_provider.dart';

class ProfessorTurmasScreen extends StatefulWidget {
  const ProfessorTurmasScreen({super.key});

  @override
  State<ProfessorTurmasScreen> createState() => _ProfessorTurmasScreenState();
}

class _ProfessorTurmasScreenState extends State<ProfessorTurmasScreen> {
  @override
  void initState() {
    super.initState();
    // Recarregar turmas quando a tela for exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTurmas();
    });
  }

  Future<void> _carregarTurmas() async {
    debugPrint('ProfessorTurmasScreen: Recarregando turmas...');
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    await turmaProvider.recarregarTurmas();

    // Verificar se as turmas foram carregadas
    final turmas = turmaProvider.turmasProfessor;
    debugPrint('ProfessorTurmasScreen: Turmas carregadas: ${turmas.length}');
    for (var turma in turmas) {
      debugPrint(
          'ProfessorTurmasScreen: Turma: ${turma.id} - ${turma.nome} - ${turma.codigo}');
    }
  }

  Future<void> _sincronizarTurmasUsuario() async {
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sincronizando turmas...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Salvar as turmas atuais para não perdê-las na sincronização
    final turmasAtuais = List<Turma>.from(turmaProvider.turmas);
    debugPrint('ProfessorTurmasScreen: Turmas atuais: ${turmasAtuais.length}');
    for (var turma in turmasAtuais) {
      debugPrint(
          'ProfessorTurmasScreen: Turma atual: ${turma.id} - ${turma.nome}');
    }

    // Verificar se o usuário já tem turmas associadas
    final user = authProvider.user!;
    if (user.turmas.isNotEmpty) {
      // Buscar turmas pelos IDs associados ao usuário
      await turmaProvider.buscarTurmasPorIds(user.turmas);

      // Verificar se alguma turma atual não está na lista carregada do usuário
      final turmasCarregadas = turmaProvider.turmas;
      final turmasCarregadasIds = turmasCarregadas.map((t) => t.id).toSet();
      final turmasAusentes = turmasAtuais
          .where((t) => !turmasCarregadasIds.contains(t.id))
          .toList();

      if (turmasAusentes.isNotEmpty) {
        debugPrint(
            'ProfessorTurmasScreen: Encontradas ${turmasAusentes.length} turmas ausentes');

        // Adicionar as turmas ausentes de volta à lista
        for (var turma in turmasAusentes) {
          if (!turmasCarregadasIds.contains(turma.id)) {
            debugPrint(
                'ProfessorTurmasScreen: Adicionando turma ausente: ${turma.id} - ${turma.nome}');
            turmaProvider.adicionarTurmaLocal(turma);
          }
        }

        // Atualizar o usuário com todas as turmas (incluindo as ausentes)
        final todosIds =
            {...user.turmas, ...turmasAusentes.map((t) => t.id)}.toList();
        final updatedUser = user.copyWith(turmas: todosIds);
        final success = await authProvider.updateUser(updatedUser);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Turmas sincronizadas e atualizadas: ${todosIds.length}'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao atualizar turmas do usuário'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Turmas carregadas: ${turmaProvider.turmas.length}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      return;
    }

    // Se o usuário não tem turmas associadas, buscar todas as turmas do professor
    // e atualizar o usuário
    await turmaProvider.recarregarTurmas();
    final turmas = turmaProvider.turmasProfessor;

    if (turmas.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma turma encontrada para sincronizar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Extrair os IDs das turmas
    final turmaIds = turmas.map((t) => t.id).toList();

    // Atualizar o usuário com os IDs das turmas
    final updatedUser = user.copyWith(turmas: turmaIds);

    final success = await authProvider.updateUser(updatedUser);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Turmas sincronizadas com sucesso (${turmaIds.length} turmas)'),
            backgroundColor: Colors.green,
          ),
        );

        // Recarregar turmas novamente
        await turmaProvider.buscarTurmasPorIds(turmaIds);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao sincronizar turmas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cadastrarNovoAluno() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroAlunoScreen(),
      ),
    ).then((_) => _carregarTurmas());
  }

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final turmas = turmaProvider.turmasProfessor;
    final isLoading = turmaProvider.isLoading;

    return RefreshIndicator(
      onRefresh: _carregarTurmas,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Minhas Turmas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          color: AppTheme.primaryColor),
                      onPressed: () {
                        _carregarTurmas();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Atualizando turmas...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      tooltip: 'Atualizar turmas',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.sync, color: AppTheme.primaryColor),
                      onPressed: _sincronizarTurmasUsuario,
                      tooltip: 'Sincronizar turmas com o usuário',
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add,
                          color: AppTheme.primaryColor),
                      onPressed: _cadastrarNovoAluno,
                      tooltip: 'Cadastrar novo aluno',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppTheme.primaryColor, size: 32),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NovaTurmaScreen()),
                        ).then((_) => _carregarTurmas());
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (turmas.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma turma encontrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crie uma nova turma clicando no botão (+)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NovaTurmaScreen()),
                              ).then((_) => _carregarTurmas());
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Criar Nova Turma'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _cadastrarNovoAluno,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Cadastrar Aluno'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turma = turmas[index];
                    return _buildTurmaCard(context, turma);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurmaCard(BuildContext context, Turma turma) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalheTurmaScreen(turmaId: turma.id),
            ),
          ).then((_) => _carregarTurmas());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Código: ${turma.codigo}',
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${turma.alunos.length} alunos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.assignment,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${turma.atividades.length} atividades',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CadastroAlunoScreen(
                            turmaIdsPreSelecionadas: [turma.id],
                          ),
                        ),
                      ).then((_) => _carregarTurmas());
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Adicionar Aluno'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
