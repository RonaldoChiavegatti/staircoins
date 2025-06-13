import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/providers/produto_provider.dart';
import 'package:staircoins/screens/aluno/aluno_atividades_screen.dart';
import 'package:staircoins/screens/aluno/aluno_produtos_screen.dart';
import 'package:staircoins/screens/aluno/aluno_turmas_screen.dart';
import 'package:staircoins/screens/aluno/turma/entrar_turma_screen.dart';
import 'package:staircoins/screens/aluno/turma/detalhe_turma_aluno_screen.dart';
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

class AlunoDashboardScreen extends StatefulWidget {
  const AlunoDashboardScreen({super.key});

  @override
  State<AlunoDashboardScreen> createState() => _AlunoDashboardScreenState();
}

class _AlunoDashboardScreenState extends State<AlunoDashboardScreen> {
  bool _isLoading = false;
  List<Atividade> _atividadesPendentes = [];
  List<Produto> _produtosDestaque = [];

  @override
  void initState() {
    super.initState();
    // Recarregar turmas e atividades quando a tela for exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _produtosDestaque = []; // Limpar produtos antigos
    });

    try {
      final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final atividadeProvider =
          Provider.of<AtividadeProvider>(context, listen: false);
      final produtoProvider =
          Provider.of<ProdutoProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        final user = authProvider.user;
        debugPrint(
            'AlunoDashboardScreen: Carregando dados para o aluno: ${user?.id}');

        if (user != null && user.turmas.isNotEmpty) {
          // Carregar turmas - forçar atualização completa
          await turmaProvider.recarregarTurmas();
          await turmaProvider.buscarTurmasPorIds(user.turmas);

          // Carregar atividades de todas as turmas do aluno
          _atividadesPendentes = [];
          for (var turmaId in user.turmas) {
            await atividadeProvider.fetchAtividadesByTurma(turmaId);
            final atividadesTurma = atividadeProvider.atividades
                .where((a) => a.status == AtividadeStatus.pendente)
                .toList();
            _atividadesPendentes.addAll(atividadesTurma);
          }

          // Ordenar atividades por data de entrega
          _atividadesPendentes
              .sort((a, b) => a.dataEntrega.compareTo(b.dataEntrega));

          // Limitar a 3 atividades pendentes mais próximas
          if (_atividadesPendentes.length > 3) {
            _atividadesPendentes = _atividadesPendentes.sublist(0, 3);
          }

          // Buscar turmas do aluno para obter os IDs dos professores
          final turmas = turmaProvider.getTurmasAluno();
          final professoresIds =
              turmas.map((t) => t.professorId).toSet().toList();

          debugPrint('AlunoDashboardScreen: Turmas do aluno: ${turmas.length}');
          for (var turma in turmas) {
            debugPrint(
                'AlunoDashboardScreen: Turma: ${turma.id} - ${turma.nome} - Professor: ${turma.professorId}');
          }

          debugPrint(
              'AlunoDashboardScreen: Professores das turmas: $professoresIds');

          // Verificar se temos professores
          if (professoresIds.isEmpty) {
            debugPrint(
                'ALERTA: Nenhum professor encontrado para as turmas do aluno!');
          }

          try {
            // Primeiro recarregar todos os produtos para garantir dados atualizados
            await produtoProvider.carregarProdutos();

            debugPrint(
                'AlunoDashboardScreen: Buscando produtos das turmas do aluno e seus professores');

            final produtosTurma = await produtoProvider.buscarProdutosPorTurmas(
                user.turmas,
                professoresIds: professoresIds);

            debugPrint(
                'AlunoDashboardScreen: Encontrados ${produtosTurma.length} produtos para as turmas do aluno');
            for (var produto in produtosTurma) {
              debugPrint(
                  'AlunoDashboardScreen: Produto: ${produto.nome}, turmaId: ${produto.turmaId}, professorId: ${produto.professorId}');
            }

            _produtosDestaque = produtosTurma;

            // Ordenar e limitar produtos
            _produtosDestaque.sort((a, b) => a.preco.compareTo(b.preco));
            if (_produtosDestaque.length > 4) {
              _produtosDestaque = _produtosDestaque.sublist(0, 4);
            }

            debugPrint(
                'AlunoDashboardScreen: Total de ${_produtosDestaque.length} produtos em destaque');
          } catch (e) {
            debugPrint('AlunoDashboardScreen: Erro ao buscar produtos: $e');
          }
        } else {
          debugPrint('AlunoDashboardScreen: Aluno não está em nenhuma turma');
          _atividadesPendentes = [];
          _produtosDestaque = [];
        }
      }
    } catch (e) {
      debugPrint('AlunoDashboardScreen: Erro ao carregar dados: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final user = authProvider.user;
    final minhasTurmas = turmaProvider.getTurmasAluno();
    final coins = user?.staircoins ?? 0;

    // Próxima meta (simulação)
    const proximaMeta = 200;
    final progressoMeta = (coins / proximaMeta) * 100;

    return RefreshIndicator(
      onRefresh: _carregarDados,
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
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
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
                Row(
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        final homeState = context
                            .findAncestorStateOfType<_AlunoHomeScreenState>();
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
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => const EntrarTurmaScreen(),
                                ),
                              )
                              .then((_) => _carregarDados());
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
                itemCount: minhasTurmas.length > 3 ? 3 : minhasTurmas.length,
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
                    final homeState = context
                        .findAncestorStateOfType<_AlunoHomeScreenState>();
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

            if (_atividadesPendentes.isEmpty)
              const Card(
                color: AppTheme.mutedColor,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: AppTheme.mutedForegroundColor,
                      ),
                      SizedBox(height: 16),
                      Text(
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
                itemCount: _atividadesPendentes.length,
                itemBuilder: (context, index) {
                  final atividade = _atividadesPendentes[index];
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
                                  atividade.titulo,
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
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: AppTheme.warningColor,
                                    ),
                                    SizedBox(width: 4),
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
                            'Entrega: ${atividade.dataEntrega.toString().split(' ')[0]}',
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
                              '${atividade.pontuacao} moedas',
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
                    final homeState = context
                        .findAncestorStateOfType<_AlunoHomeScreenState>();
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

            _isLoading && _produtosDestaque.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _produtosDestaque.isEmpty
                    ? const Card(
                        color: AppTheme.mutedColor,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.card_giftcard_outlined,
                                size: 48,
                                color: AppTheme.mutedForegroundColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum produto disponível no momento',
                                style: TextStyle(
                                    color: AppTheme.mutedForegroundColor),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _produtosDestaque.length,
                        itemBuilder: (context, index) {
                          final produto = _produtosDestaque[index];
                          final temSaldo = coins >= produto.preco;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagem
                                AspectRatio(
                                  aspectRatio: 1.5,
                                  child: Container(
                                    width: double.infinity,
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    child: produto.imagem != null &&
                                            produto.imagem!.isNotEmpty
                                        ? Image.network(
                                            produto.imagem!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                              child: Icon(
                                                Icons.card_giftcard,
                                                size: 40,
                                                color: AppTheme
                                                    .mutedForegroundColor,
                                              ),
                                            ),
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.card_giftcard,
                                              size: 40,
                                              color:
                                                  AppTheme.mutedForegroundColor,
                                            ),
                                          ),
                                  ),
                                ),

                                // Informações
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 8, 10, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              produto.nome,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              produto.descricao,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.monetization_on,
                                                        color: AppTheme
                                                            .primaryColor,
                                                        size: 16),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${produto.preco}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppTheme
                                                            .primaryColor,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  temSaldo
                                                      ? 'Disponível'
                                                      : 'Faltam ${produto.preco - coins}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: temSaldo
                                                        ? AppTheme.successColor
                                                        : Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              height: 32,
                                              margin: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: ElevatedButton(
                                                onPressed: temSaldo
                                                    ? () {
                                                        _showComprarDialog(
                                                            context,
                                                            produto,
                                                            coins,
                                                            user?.id);
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 4),
                                                  textStyle: const TextStyle(
                                                      fontSize: 13),
                                                  minimumSize:
                                                      const Size.fromHeight(32),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(temSaldo
                                                      ? 'Comprar'
                                                      : 'Moedas insuficientes'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  void _showComprarDialog(BuildContext context, Produto produto, int moedas,
      String? alunoId) async {
    final scaffoldContext = context;
    final saldoSuficiente = moedas >= produto.preco;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comprar ${produto.nome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preço: ${produto.preco} StairCoins'),
            const SizedBox(height: 8),
            Text('Seu saldo: $moedas StairCoins'),
            if (!saldoSuficiente) ...[
              const SizedBox(height: 12),
              const Text(
                'Saldo insuficiente para realizar esta compra.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: saldoSuficiente
                ? () async {
                    if (alunoId == null) return;
                    final produtoProvider = Provider.of<ProdutoProvider>(
                        scaffoldContext,
                        listen: false);
                    final authProvider = Provider.of<AuthProvider>(
                        scaffoldContext,
                        listen: false);

                    final codigo = await produtoProvider.trocarProduto(
                      produtoId: produto.id,
                      alunoId: alunoId,
                      moedasAluno: moedas,
                      authProvider: authProvider,
                    );

                    Navigator.of(ctx).pop();

                    if (codigo == 'MOEDAS_INSUFICIENTES') {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text('Moedas insuficientes!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (codigo != null) {
                      // Recarregar dados após compra bem-sucedida
                      _carregarDados();

                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text('Troca realizada! Código: $codigo'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao realizar troca.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                : null,
            child: const Text('Confirmar Compra'),
          ),
        ],
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
                  builder: (_) => DetalheTurmaAlunoScreen(turmaId: turma.id),
                ),
              )
              .then((_) => _carregarDados());
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
