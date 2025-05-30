import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/professor/professor_atividades_screen.dart';
import 'package:staircoins/screens/professor/professor_produtos_screen.dart';
import 'package:staircoins/screens/professor/cadastro_produto_screen.dart';
import 'package:staircoins/screens/professor/professor_turmas_screen.dart';
import 'package:staircoins/screens/professor/turma/nova_turma_screen.dart';
import 'package:staircoins/screens/professor/atividade/nova_atividade_screen.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StairCoins'),
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

class ProfessorDashboardScreen extends StatelessWidget {
  const ProfessorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final user = authProvider.user;
    final minhasTurmas = turmaProvider.getMinhasTurmas();

    // Dados mockados para demonstração
    final stats = {
      'totalAlunos': 28,
      'atividadesAtivas': 5,
      'produtosCadastrados': 12,
    };

    // Atividades recentes (mockadas)
    final atividadesRecentes = [
      {
        'id': '1',
        'titulo': 'Trabalho de Matemática',
        'dataEntrega': '2023-05-15',
        'pontuacao': 50,
        'status': 'ativa',
      },
      {
        'id': '2',
        'titulo': 'Redação sobre Meio Ambiente',
        'dataEntrega': '2023-05-20',
        'pontuacao': 30,
        'status': 'ativa',
      },
    ];

    return SingleChildScrollView(
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
              TextButton(
                onPressed: () {
                  (context.findAncestorStateOfType<_ProfessorHomeScreenState>()
                          as _ProfessorHomeScreenState)
                      // ignore: invalid_use_of_protected_member
                      .setState(() {
                    (context.findAncestorStateOfType<_ProfessorHomeScreenState>()
                            as _ProfessorHomeScreenState)
                        ._selectedIndex = 1;
                  });
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (minhasTurmas.isEmpty)
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NovaTurmaScreen(),
                          ),
                        );
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
                  (context.findAncestorStateOfType<_ProfessorHomeScreenState>()
                          as _ProfessorHomeScreenState)
                      // ignore: invalid_use_of_protected_member
                      .setState(() {
                    (context.findAncestorStateOfType<_ProfessorHomeScreenState>()
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
                              // TODO: Implementar detalhes da atividade
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
    );
  }

  Widget _buildTurmaCard(BuildContext context, Turma turma) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Implementar detalhes da turma
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
