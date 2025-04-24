import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/aluno/aluno_atividades_screen.dart';
import 'package:staircoins/screens/aluno/aluno_produtos_screen.dart';
import 'package:staircoins/screens/aluno/aluno_turmas_screen.dart';
import 'package:staircoins/screens/aluno/turma/entrar_turma_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/widgets/app_drawer.dart';

class AlunoHomeScreen extends StatefulWidget {
  const AlunoHomeScreen({super.key});

  @override
  State<AlunoHomeScreen> createState() => _AlunoHomeScreenState();
}

class _AlunoHomeScreenState extends State<AlunoHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AlunoDashboardScreen(),
    const AlunoTurmasScreen(),
    const AlunoAtividadesScreen(),
    const AlunoProdutosScreen(),
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
    );
  }
}

class AlunoDashboardScreen extends StatelessWidget {
  const AlunoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final user = authProvider.user;
    final minhasTurmas = turmaProvider.getMinhasTurmas();
    final coins = user?.coins ?? 0;

    // Próxima meta (simulação)
    const proximaMeta = 200;
    final progressoMeta = (coins / proximaMeta) * 100;

    // Dados mockados para demonstração
    final atividadesPendentes = [
      {
        'id': '1',
        'titulo': 'Trabalho de Matemática',
        'dataEntrega': '2023-05-15',
        'pontuacao': 50,
        'status': 'pendente',
      },
      {
        'id': '2',
        'titulo': 'Redação sobre Meio Ambiente',
        'dataEntrega': '2023-05-20',
        'pontuacao': 30,
        'status': 'pendente',
      },
    ];

    final produtosDestaque = [
      {
        'id': '1',
        'nome': 'Caneta Personalizada',
        'descricao': 'Caneta com o logo da escola',
        'preco': 50,
        'imagem': 'assets/images/caneta.png',
      },
      {
        'id': '2',
        'nome': 'Caderno Exclusivo',
        'descricao': 'Caderno capa dura com 100 folhas',
        'preco': 150,
        'imagem': 'assets/images/caderno.png',
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
            'Bem-vindo ao seu painel',
            style: TextStyle(color: AppTheme.mutedForegroundColor),
          ),
          const SizedBox(height: 24),

          // Card de saldo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$coins',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star,
                      color: AppTheme.warningColor,
                      size: 28,
                    ),
                  ],
                ),
                const Text(
                  'moedas disponíveis',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Próxima meta: 200 moedas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$coins/200',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressoMeta / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
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
                  final homeState = context.findAncestorStateOfType<_AlunoHomeScreenState>();
                  if (homeState != null) {
                    homeState.setState(() {
                      homeState._selectedIndex = 1;
                    });
                  }
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
                      'Você ainda não está em nenhuma turma',
                      style: TextStyle(color: AppTheme.mutedForegroundColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EntrarTurmaScreen(),
                          ),
                        );
                      },
                      child: const Text('Entrar em uma Turma'),
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

          // Atividades Pendentes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Atividades Pendentes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {
                  final homeState = context.findAncestorStateOfType<_AlunoHomeScreenState>();
                  if (homeState != null) {
                    homeState.setState(() {
                      homeState._selectedIndex = 2;
                    });
                  }
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (atividadesPendentes.isEmpty)
            Card(
              color: AppTheme.mutedColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 48,
                      color: AppTheme.mutedForegroundColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Você não tem atividades pendentes no momento',
                      style: TextStyle(color: AppTheme.mutedForegroundColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: atividadesPendentes.length,
              itemBuilder: (context, index) {
                final atividade = atividadesPendentes[index];
                return Card(
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
                                color: AppTheme.warningColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppTheme.warningColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pendente',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.warningColor,
                                    ),
                                  ),
                                ],
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
                      ],
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Produtos em Destaque
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Produtos em Destaque',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {
                  final homeState = context.findAncestorStateOfType<_AlunoHomeScreenState>();
                  if (homeState != null) {
                    homeState.setState(() {
                      homeState._selectedIndex = 3;
                    });
                  }
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: produtosDestaque.length,
            itemBuilder: (context, index) {
              final produto = produtosDestaque[index];
              final temSaldo = coins >= (produto['preco'] as int);

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: AppTheme.mutedColor,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppTheme.mutedForegroundColor,
                          ),
                        ),
                      ),
                    ),

                    // Informações
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produto['nome'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${produto['preco']} 🪙',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                temSaldo ? 'Disponível' : 'Faltam ${(produto['preco'] as int) - coins}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: temSaldo ? AppTheme.successColor : AppTheme.mutedForegroundColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: temSaldo
                                ? () {
                                    // TODO: Implementar troca de produto
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                            ),
                            child: Text(temSaldo ? 'Trocar' : 'Moedas insuficientes'),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      turma.descricao,
                      style: const TextStyle(
                        color: AppTheme.mutedForegroundColor,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.groups_outlined,
                color: AppTheme.mutedForegroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
