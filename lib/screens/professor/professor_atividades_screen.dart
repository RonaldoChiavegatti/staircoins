import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/screens/professor/atividade/correcao_entregas_screen.dart';

class ProfessorAtividadesScreen extends StatefulWidget {
  const ProfessorAtividadesScreen({super.key});

  @override
  State<ProfessorAtividadesScreen> createState() =>
      _ProfessorAtividadesScreenState();
}

class _ProfessorAtividadesScreenState extends State<ProfessorAtividadesScreen> {
  Turma? _turmaSelecionada;
  String? _ultimoTurmaIdBuscado;
  bool _isLoadingTurmas = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarDados();
    });
  }

  Future<void> _inicializarDados() async {
    setState(() {
      _isLoadingTurmas = true;
    });

    final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
    await turmaProvider.recarregarTurmas();

    final minhasTurmas = turmaProvider.getMinhasTurmas();
    if (minhasTurmas.isNotEmpty) {
      setState(() {
        _turmaSelecionada = minhasTurmas.first;
        _isLoadingTurmas = false;
      });
      _buscarAtividades();
    } else {
      setState(() {
        _isLoadingTurmas = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoadingTurmas) {
      final turmaProvider = Provider.of<TurmaProvider>(context);
      final minhasTurmas = turmaProvider.getMinhasTurmas();

      if (minhasTurmas.isNotEmpty) {
        if (_turmaSelecionada == null) {
          setState(() {
            _turmaSelecionada = minhasTurmas.first;
          });
          _buscarAtividades();
        }
      }
    }
  }

  Future<void> _buscarAtividades() async {
    if (_turmaSelecionada != null &&
        _turmaSelecionada!.id != _ultimoTurmaIdBuscado) {
      _ultimoTurmaIdBuscado = _turmaSelecionada!.id;
      await Provider.of<AtividadeProvider>(context, listen: false)
          .fetchAtividadesByTurma(_turmaSelecionada!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final minhasTurmas = turmaProvider.getMinhasTurmas();
    final atividadeProvider = Provider.of<AtividadeProvider>(context);
    final atividades = atividadeProvider.atividades;
    final isLoading = atividadeProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Atividades por Turma')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoadingTurmas
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Turma>(
                    value: _turmaSelecionada,
                    items: minhasTurmas.map((turma) {
                      return DropdownMenuItem<Turma>(
                        value: turma,
                        child: Text(turma.nome),
                      );
                    }).toList(),
                    onChanged: (turma) {
                      if (turma != null && turma != _turmaSelecionada) {
                        setState(() {
                          _turmaSelecionada = turma;
                        });
                        _buscarAtividades();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Selecione a Turma',
                      border: OutlineInputBorder(),
                    ),
                  ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : atividades.isEmpty
                    ? const Center(
                        child: Text(
                            'Nenhuma atividade encontrada para esta turma.'))
                    : RefreshIndicator(
                        onRefresh: _buscarAtividades,
                        child: ListView.builder(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: atividade.status ==
                                                      AtividadeStatus.pendente
                                                  ? AppTheme.warningColor
                                                      .withOpacity(0.2)
                                                  : atividade.status ==
                                                          AtividadeStatus
                                                              .entregue
                                                      ? AppTheme.successColor
                                                          .withOpacity(0.2)
                                                      : AppTheme.errorColor
                                                          .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              atividade.status ==
                                                      AtividadeStatus.pendente
                                                  ? 'Pendente'
                                                  : atividade.status ==
                                                          AtividadeStatus
                                                              .entregue
                                                      ? 'Entregue'
                                                      : 'Atrasado',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: atividade.status ==
                                                        AtividadeStatus.pendente
                                                    ? AppTheme.warningColor
                                                    : atividade.status ==
                                                            AtividadeStatus
                                                                .entregue
                                                        ? AppTheme.successColor
                                                        : AppTheme.errorColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Entrega: ${atividade.dataEntrega.toString().split(' ').first}',
                                      style: const TextStyle(
                                        color: AppTheme.mutedForegroundColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${atividade.pontuacao} moedas',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Turma: ${_turmaSelecionada?.nome ?? ''}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme
                                                        .mutedForegroundColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        CorrecaoEntregasScreen(
                                                            atividade:
                                                                atividade),
                                                  ),
                                                )
                                                .then(
                                                    (_) => _buscarAtividades());
                                          },
                                          child: const Text('Corrigir'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
