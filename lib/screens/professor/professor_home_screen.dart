import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/screens/professor/professor_atividades_screen.dart';
import 'package:staircoins/screens/professor/professor_produtos_screen.dart';
import 'package:staircoins/screens/professor/cadastro_produto_screen.dart';
import 'package:staircoins/screens/professor/professor_turmas_screen.dart';
import 'package:staircoins/screens/professor/turma/nova_turma_screen.dart';
import 'package:staircoins/screens/professor/turma/detalhe_turma_screen.dart';
import 'package:staircoins/screens/professor/atividade/nova_atividade_screen.dart';
import 'package:staircoins/screens/professor/atividade/correcao_entregas_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/widgets/app_drawer.dart';
import 'package:staircoins/widgets/stat_card.dart';

class ProfessorHomeScreen extends StatefulWidget {
  const ProfessorHomeScreen({super.key});

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProfessorDashboardScreen(),
    const ProfessorTurmasScreen(),
    const ProfessorAtividadesScreen(),
    const ProfessorProdutosScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar o TurmaProvider quando a tela for exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarProviders();
    });
  }

  Future<void> _inicializarProviders() async {
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    debugPrint('ProfessorHomeScreen: Inicializando TurmaProvider');

    // Verificar se o usuário está autenticado
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      debugPrint(
          'ProfessorHomeScreen: Usuário autenticado: ${authProvider.user?.name} (${authProvider.user?.id})');

      // Forçar o carregamento das turmas
      await turmaProvider.init();

      // Verificar se as turmas foram carregadas
      final turmas = turmaProvider.turmasProfessor;
      debugPrint('ProfessorHomeScreen: Turmas carregadas: ${turmas.length}');
      for (var turma in turmas) {
        debugPrint(
            'ProfessorHomeScreen: Turma: ${turma.id} - ${turma.nome} - ${turma.codigo}');
      }
    } else {
      debugPrint('ProfessorHomeScreen: Usuário não autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StarCoins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Turmas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Atividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            label: 'Produtos',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação baseada na tela atual
          switch (_selectedIndex) {
            case 1: // Turmas
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NovaTurmaScreen(),
                ),
              );
              break;
            case 2: // Atividades
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NovaAtividadeScreen(),
                ),
              );
              break;
            case 3: // Produtos
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CadastroProdutoScreen(),
                ),
              );

              break;
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfessorDashboardScreen extends StatefulWidget {
  const ProfessorDashboardScreen({super.key});

  @override
  State<ProfessorDashboardScreen> createState() =>
      _ProfessorDashboardScreenState();
}

class _ProfessorDashboardScreenState extends State<ProfessorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Recarregar turmas quando a tela for exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTurmas();
      _carregarAtividades();
    });
  }

  Future<void> _carregarTurmas() async {
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    await turmaProvider.recarregarTurmas();
  }

  Future<void> _carregarAtividades() async {
    final atividadeProvider =
        Provider.of<AtividadeProvider>(context, listen: false);
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    final minhasTurmas = turmaProvider.getMinhasTurmas();
    if (minhasTurmas.isNotEmpty) {
      await atividadeProvider.fetchAtividadesByTurma(minhasTurmas.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final atividadeProvider = Provider.of<AtividadeProvider>(context);
    final user = authProvider.user;
    final minhasTurmas = turmaProvider.getMinhasTurmas();
    final isLoading = turmaProvider.isLoading;
    final atividades = atividadeProvider.atividades;

    // Dados reais para estatísticas
    final stats = {
      'totalAlunos': minhasTurmas.fold<int>(
          0, (prev, turma) => prev + turma.alunos.length),
      'atividadesAtivas': atividades.length,
      'produtosCadastrados':
          12, // Pode ser substituído por dados reais se disponível
    };

    // Usar atividades reais do Firebase
    final atividadesRecentes = atividades
        .take(2)
        .map((a) => {
              'id': a.id,
              'titulo': a.titulo,
              'dataEntrega': a.dataEntrega.toString().split(' ').first,
              'pontuacao': a.pontuacao,
              'status': a.status.toString().split('.').last,
            })
        .toList();

    return RefreshIndicator(
      onRefresh: _carregarTurmas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Text(
              'Olá, ${user?.name}!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Text(
              'Bem-vindo ao seu painel de controle',
              style: TextStyle(color: AppTheme.mutedForegroundColor),
            ),
            const SizedBox(height: 24),

            // Cards de estatísticas
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Alunos',
                    value: stats['totalAlunos'].toString(),
                    icon: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Atividades',
                    value: stats['atividadesAtivas'].toString(),
                    icon: Icons.assignment_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Minhas Turmas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Minhas Turmas',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          color: AppTheme.primaryColor),
                      onPressed: _carregarTurmas,
                      tooltip: 'Atualizar turmas',
                    ),
                    TextButton(
                      onPressed: () {
                        (context.findAncestorStateOfType<
                                    _ProfessorHomeScreenState>()
                                as _ProfessorHomeScreenState)
                            // ignore: invalid_use_of_protected_member
                            .setState(() {
                          (context.findAncestorStateOfType<
                                      _ProfessorHomeScreenState>()
                                  as _ProfessorHomeScreenState)
                              ._selectedIndex = 1;
                        });
                      },
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Indicador de carregamento ou conteúdo
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (minhasTurmas.isEmpty)
              Card(
                color: AppTheme.mutedColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 48,
                        color: AppTheme.mutedForegroundColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Você ainda não tem turmas',
                        style: TextStyle(color: AppTheme.mutedForegroundColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => const NovaTurmaScreen(),
                                ),
                              )
                              .then((_) => _carregarTurmas());
                        },
                        child: const Text('Criar Turma'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: minhasTurmas.length,
                itemBuilder: (context, index) {
                  final turma = minhasTurmas[index];
                  return _buildTurmaCard(context, turma);
                },
              ),

            const SizedBox(height: 24),

            // Atividades Recentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atividades Recentes',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () {
                    (context.findAncestorStateOfType<
                                _ProfessorHomeScreenState>()
                            as _ProfessorHomeScreenState)
                        // ignore: invalid_use_of_protected_member
                        .setState(() {
                      (context.findAncestorStateOfType<
                                  _ProfessorHomeScreenState>()
                              as _ProfessorHomeScreenState)
                          ._selectedIndex = 2;
                    });
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: atividadesRecentes.length,
              itemBuilder: (context, index) {
                final atividade = atividadesRecentes[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              atividade['titulo'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                                atividade['status'] == 'ativa'
                                    ? 'Ativa'
                                    : 'Encerrada',
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
                            TextButton(
                              onPressed: () {
                                // Navegar para a tela de correção da atividade
                                final atividadeObj =
                                    atividadeProvider.getAtividadeById(
                                        atividade['id'] as String);
                                if (atividadeObj != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CorrecaoEntregasScreen(
                                          atividade: atividadeObj),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Ver detalhes'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurmaCard(BuildContext context, Turma turma) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navegar para a tela de detalhes da turma
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => DetalheTurmaScreen(turmaId: turma.id),
                ),
              )
              .then((_) => _carregarTurmas());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turma.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${turma.alunos.length} alunos',
                      style: const TextStyle(
                        color: AppTheme.mutedForegroundColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
