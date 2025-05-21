import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/theme/app_theme.dart';

class DetalheTurmaAlunoScreen extends StatefulWidget {
  final String turmaId;

  const DetalheTurmaAlunoScreen({
    super.key,
    required this.turmaId,
  });

  @override
  State<DetalheTurmaAlunoScreen> createState() => _DetalheTurmaAlunoScreenState();
}

class _DetalheTurmaAlunoScreenState extends State<DetalheTurmaAlunoScreen> with SingleTickerProviderStateMixin {
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Código: ${turma.codigo}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                icon: Icon(Icons.assignment_outlined),
                text: 'Atividades',
              ),
              Tab(
                icon: Icon(Icons.people_outline),
                text: 'Colegas',
              ),
            ],
          ),

          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAtividadesTab(turma),
                _buildColegasTab(turma),
              ],
            ),
          ),
        ],
      ),
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

    if (atividades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppTheme.mutedForegroundColor,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma atividade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Não há atividades disponíveis para esta turma no momento',
              style: TextStyle(
                color: AppTheme.mutedForegroundColor,
              ),
              textAlign: TextAlign.center,
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
                        color: AppTheme.warningColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Pendente',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.warningColor,
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

  Widget _buildColegasTab(Turma turma) {
    // Dados mockados para demonstração
    final alunos = [
      {'id': '2', 'nome': 'Aluno Demo', 'email': 'aluno@exemplo.com'},
      {'id': '3', 'nome': 'Maria Silva', 'email': 'maria@exemplo.com'},
      {'id': '4', 'nome': 'João Santos', 'email': 'joao@exemplo.com'},
    ].where((aluno) => turma.alunos.contains(aluno['id'])).toList();

    if (alunos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.mutedForegroundColor,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum colega na turma',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Você é o primeiro aluno nesta turma',
              style: TextStyle(
                color: AppTheme.mutedForegroundColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
          ),
        );
      },
    );
  }
}
