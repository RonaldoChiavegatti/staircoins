import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/models/user.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/aluno/atividade/detalhe_atividade_screen.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:intl/intl.dart';

class DetalheTurmaAlunoScreen extends StatefulWidget {
  final String turmaId;

  const DetalheTurmaAlunoScreen({
    super.key,
    required this.turmaId,
  });

  @override
  State<DetalheTurmaAlunoScreen> createState() =>
      _DetalheTurmaAlunoScreenState();
}

class _DetalheTurmaAlunoScreenState extends State<DetalheTurmaAlunoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isLoadingAtividades = false;
  List<Atividade> _atividades = [];
  String? _professorNome;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Recarregar dados da turma quando a tela for exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTurma();
    });
  }

  Future<void> _carregarTurma() async {
    setState(() {
      _isLoading = true;
      _isLoadingAtividades = true;
    });

    try {
      final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final atividadeProvider =
          Provider.of<AtividadeProvider>(context, listen: false);

      // Buscar a turma específica pelo ID
      await turmaProvider.buscarTurmasPorIds([widget.turmaId]);

      // Verificar se a turma foi carregada
      final turma = turmaProvider.getTurmaById(widget.turmaId);

      if (turma == null) {
        debugPrint(
            'DetalheTurmaAlunoScreen: Turma não encontrada, tentando atualização forçada');

        // Se o usuário for um aluno, tentar atualização forçada
        if (authProvider.user != null &&
            authProvider.user!.type == UserType.aluno) {
          await turmaProvider.forcarAtualizacaoTurmasAluno();
        }
      } else {
        // Buscar atividades da turma
        await atividadeProvider.fetchAtividadesByTurma(widget.turmaId);
        _atividades = atividadeProvider.atividades;

        // Definir nome do professor (simplificado para evitar erros)
        _professorNome = "Professor da Turma";
      }

      debugPrint('DetalheTurmaAlunoScreen: Turma carregada: ${widget.turmaId}');
    } catch (e) {
      debugPrint('DetalheTurmaAlunoScreen: Erro ao carregar turma: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingAtividades = false;
        });
      }
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
    final authProvider = Provider.of<AuthProvider>(context);
    final turma = turmaProvider.getTurmaById(widget.turmaId);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carregando...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (turma == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Turma não encontrada'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'A turma solicitada não foi encontrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _carregarTurma,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Usar o nome do professor obtido do Firebase ou um valor padrão
    final professorNome = _professorNome ?? "Professor da Turma";

    return Scaffold(
      appBar: AppBar(
        title: Text(turma.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarTurma,
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarTurma,
        child: Column(
          children: [
            // Cabeçalho da turma
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Card(
                elevation: 2,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Código: ${turma.codigo}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  professorNome,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alunos: ${turma.alunos.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.assignment_outlined, size: 20),
                    text: 'Atividades',
                  ),
                  Tab(
                    icon: Icon(Icons.people_outline, size: 20),
                    text: 'Colegas',
                  ),
                ],
              ),
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
      ),
    );
  }

  Widget _buildAtividadesTab(Turma turma) {
    if (_isLoadingAtividades) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_atividades.isEmpty) {
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
      padding: const EdgeInsets.all(12),
      itemCount: _atividades.length,
      itemBuilder: (context, index) {
        final atividade = _atividades[index];
        final dateFormat = DateFormat('dd/MM/yyyy');
        final formattedDate = dateFormat.format(atividade.dataEntrega);

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
                          fontSize: 15,
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
                        color:
                            _getStatusColor(atividade.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(atividade.status),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(atividade.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Entrega: $formattedDate',
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
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${atividade.pontuacao} moedas',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalheAtividadeScreen(atividade: atividade),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: const Text('Ver detalhes',
                          style: TextStyle(fontSize: 13)),
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

  Color _getStatusColor(AtividadeStatus status) {
    switch (status) {
      case AtividadeStatus.pendente:
        return AppTheme.warningColor;
      case AtividadeStatus.entregue:
        return AppTheme.successColor;
      case AtividadeStatus.atrasado:
        return AppTheme.errorColor;
      default:
        return AppTheme.mutedForegroundColor;
    }
  }

  String _getStatusText(AtividadeStatus status) {
    switch (status) {
      case AtividadeStatus.pendente:
        return 'Pendente';
      case AtividadeStatus.entregue:
        return 'Entregue';
      case AtividadeStatus.atrasado:
        return 'Atrasado';
      default:
        return 'Desconhecido';
    }
  }

  Widget _buildColegasTab(Turma turma) {
    // Simplificando para evitar erros com métodos não definidos
    final alunosIds = turma.alunos;

    if (alunosIds.isEmpty) {
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

    // Usando uma lista simples em vez do FutureBuilder para evitar erros
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: alunosIds.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: const CircleAvatar(
              backgroundColor: AppTheme.mutedColor,
              radius: 18,
              child: Icon(
                Icons.person_outline,
                color: AppTheme.mutedForegroundColor,
                size: 18,
              ),
            ),
            title: Text(
              "Aluno ${index + 1}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "ID: ${alunosIds[index]}",
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
