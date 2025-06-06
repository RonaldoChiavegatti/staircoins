import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/professor/aluno/cadastro_aluno_screen.dart';
import 'package:staircoins/theme/app_theme.dart';

class DetalheTurmaScreen extends StatefulWidget {
  final String turmaId;

  const DetalheTurmaScreen({
    super.key,
    required this.turmaId,
  });

  @override
  State<DetalheTurmaScreen> createState() => _DetalheTurmaScreenState();
}

class _DetalheTurmaScreenState extends State<DetalheTurmaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final turma = turmaProvider.getTurmaById(widget.turmaId);

    if (turma == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Turma não encontrada'),
        ),
        body: const Center(
          child: Text('A turma solicitada não foi encontrada'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(turma.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _compartilharTurma(turma),
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho da turma
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turma.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      turma.descricao,
                      style: const TextStyle(
                        color: AppTheme.mutedForegroundColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Código: ${turma.codigo}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _copiarCodigo(turma.codigo),
                                child: const Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.people_outline),
                text: 'Alunos',
              ),
              Tab(
                icon: Icon(Icons.assignment_outlined),
                text: 'Atividades',
              ),
            ],
          ),

          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlunosTab(turma),
                _buildAtividadesTab(turma),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlunosTab(Turma turma) {
    // Dados mockados para demonstração
    final alunos = [
      {'id': '2', 'nome': 'Aluno Demo', 'email': 'aluno@exemplo.com'},
      {'id': '3', 'nome': 'Maria Silva', 'email': 'maria@exemplo.com'},
      {'id': '4', 'nome': 'João Santos', 'email': 'joao@exemplo.com'},
    ].where((aluno) => turma.alunos.contains(aluno['id'])).toList();

    return Column(
      children: [
        // Botões de ação
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${turma.alunos.length} alunos',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _compartilharTurma(turma),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _cadastrarNovoAluno(turma),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Cadastrar Aluno'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de alunos
        Expanded(
          child: alunos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppTheme.mutedForegroundColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum aluno na turma',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Compartilhe o código da turma para que os alunos possam entrar',
                        style: TextStyle(
                          color: AppTheme.mutedForegroundColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _compartilharTurma(turma),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Compartilhar Código'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => _cadastrarNovoAluno(turma),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Cadastrar Aluno'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: alunos.length,
                  itemBuilder: (context, index) {
                    final aluno = alunos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.mutedColor,
                          child: Icon(
                            Icons.person_outline,
                            color: AppTheme.mutedForegroundColor,
                          ),
                        ),
                        title: Text(aluno['nome']!),
                        subtitle: Text(aluno['email']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // TODO: Implementar menu de opções
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAtividadesTab(Turma turma) {
    // Dados mockados para demonstração
    final atividades = [
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

    if (atividades.isEmpty) {
      return Center(
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
              'Nenhuma atividade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie atividades para esta turma',
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
      );
    }

    return ListView.builder(
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
    );
  }

  void _copiarCodigo(String codigo) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _compartilharTurma(Turma turma) {
    final texto =
        'Entre na minha turma "${turma.nome}" no StairCoins usando o código: ${turma.codigo}';
    Share.share(texto);
  }

  void _cadastrarNovoAluno(Turma turma) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroAlunoScreen(
          turmaIdsPreSelecionadas: [turma.id],
        ),
      ),
    ).then((_) {
      // Recarregar dados da turma após cadastro
      final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
      turmaProvider.recarregarTurmas();
    });
  }
}
