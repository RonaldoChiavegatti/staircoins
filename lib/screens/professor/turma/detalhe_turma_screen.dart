import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:staircoins/models/user.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/screens/professor/aluno/cadastro_aluno_screen.dart';
import 'package:staircoins/screens/professor/atividade/correcao_entregas_screen.dart';
import 'package:staircoins/screens/professor/atividade/nova_atividade_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoadingAlunos = false;
  bool _isLoadingAtividades = false;
  List<User> _alunos = [];
  List<Atividade> _atividades = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Carregar dados quando a tela for exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    final atividadeProvider =
        Provider.of<AtividadeProvider>(context, listen: false);
    final turma = turmaProvider.getTurmaById(widget.turmaId);

    if (turma != null) {
      _carregarAlunos(turma);
      await atividadeProvider.fetchAtividadesByTurma(turma.id);
      setState(() {
        _atividades = atividadeProvider.atividades;
        _isLoadingAtividades = false;
      });
    }
  }

  Future<void> _carregarAlunos(Turma turma) async {
    setState(() {
      _isLoadingAlunos = true;
    });

    try {
      final alunosSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('tipo', isEqualTo: 'aluno')
          .where('turmas', arrayContains: turma.id)
          .get();

      setState(() {
        _alunos =
            alunosSnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
        _isLoadingAlunos = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar alunos: $e');
      setState(() {
        _isLoadingAlunos = false;
      });
    }
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turma.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      turma.descricao,
                      style: const TextStyle(
                        color: AppTheme.mutedForegroundColor,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Código: ${turma.codigo}',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
              ),
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              indicatorWeight: 3,
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
    return Column(
      children: [
        // Botões de ação
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: ${_alunos.length} alunos',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _compartilharTurma(turma),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Compartilhar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _cadastrarNovoAluno(turma),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Cadastrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de alunos
        Expanded(
          child: _isLoadingAlunos
              ? const Center(child: CircularProgressIndicator())
              : _alunos.isEmpty
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
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Compartilhe o código da turma para que os alunos possam entrar',
                              style: TextStyle(
                                color: AppTheme.mutedForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _compartilharTurma(turma),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Compartilhar Código'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _carregarDados(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _alunos.length,
                        itemBuilder: (context, index) {
                          final aluno = _alunos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0.5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.mutedColor,
                                  backgroundImage: aluno.photoUrl != null
                                      ? NetworkImage(aluno.photoUrl!)
                                      : null,
                                  radius: 20,
                                  child: aluno.photoUrl == null
                                      ? const Icon(
                                          Icons.person_outline,
                                          color: AppTheme.mutedForegroundColor,
                                          size: 20,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  aluno.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  aluno.email,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 24,
                                  onPressed: () {
                                    // Menu de opções para o aluno
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                                Icons.remove_circle_outline),
                                            title:
                                                const Text('Remover da turma'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              // Implementar remoção do aluno
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildAtividadesTab(Turma turma) {
    return _isLoadingAtividades
        ? const Center(child: CircularProgressIndicator())
        : _atividades.isEmpty
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
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => const NovaAtividadeScreen(),
                              ),
                            )
                            .then((_) => _carregarDados());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Atividade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _carregarDados(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _atividades.length,
                  itemBuilder: (context, index) {
                    final atividade = _atividades[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: atividade.status ==
                                            AtividadeStatus.pendente
                                        ? AppTheme.warningColor.withOpacity(0.2)
                                        : atividade.status ==
                                                AtividadeStatus.entregue
                                            ? AppTheme.successColor
                                                .withOpacity(0.2)
                                            : AppTheme.errorColor
                                                .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    atividade.status == AtividadeStatus.pendente
                                        ? 'Pendente'
                                        : atividade.status ==
                                                AtividadeStatus.entregue
                                            ? 'Entregue'
                                            : 'Atrasado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: atividade.status ==
                                              AtividadeStatus.pendente
                                          ? AppTheme.warningColor
                                          : atividade.status ==
                                                  AtividadeStatus.entregue
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Entrega: ${atividade.dataEntrega.toString().split(' ').first}',
                              style: const TextStyle(
                                color: AppTheme.mutedForegroundColor,
                                fontSize: 13,
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
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
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
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CorrecaoEntregasScreen(
                                          atividade: atividade,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
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
        'Entre na minha turma "${turma.nome}" no StarCoins usando o código: ${turma.codigo}';
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
      _carregarDados();
    });
  }
}
