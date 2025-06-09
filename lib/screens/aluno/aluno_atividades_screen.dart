import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/atividade.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/providers/entrega_atividade_provider.dart';
import 'package:staircoins/screens/aluno/atividade/detalhe_atividade_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/models/entrega_atividade.dart';

class AlunoAtividadesScreen extends StatefulWidget {
  const AlunoAtividadesScreen({super.key});

  @override
  State<AlunoAtividadesScreen> createState() => _AlunoAtividadesScreenState();
}

class _AlunoAtividadesScreenState extends State<AlunoAtividadesScreen> {
  Turma? _turmaSelecionada;
  String? _statusFilter;

  EntregaAtividade? _findEntrega(Atividade atividade, String? userId,
      EntregaAtividadeProvider entregaProvider) {
    if (userId == null) return null;
    for (final entrega in entregaProvider.entregas) {
      if (entrega.atividadeId == atividade.id && entrega.alunoId == userId) {
        return entrega;
      }
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final minhasTurmas = turmaProvider.getMinhasTurmas();
    if (_turmaSelecionada == null && minhasTurmas.isNotEmpty) {
      _turmaSelecionada = minhasTurmas.first;
      _buscarAtividades();
      // Fetch entregas for the current user once on load
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<EntregaAtividadeProvider>(context, listen: false)
            .fetchEntregasByAluno(userId);
      }
    }
  }

  void _buscarAtividades() {
    if (_turmaSelecionada != null) {
      Provider.of<AtividadeProvider>(context, listen: false)
          .fetchAtividadesByTurma(_turmaSelecionada!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final minhasTurmas = turmaProvider.getMinhasTurmas();
    final atividadeProvider = Provider.of<AtividadeProvider>(context);
    final entregaProvider = Provider.of<EntregaAtividadeProvider>(context);
    final atividades = atividadeProvider.atividades;
    final isLoading = atividadeProvider.isLoading;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Filtra atividades com base no status
    final filteredAtividades = _statusFilter == null
        ? atividades
        : atividades.where((a) {
            final entrega = _findEntrega(a, userId, entregaProvider);
            final status =
                entrega?.status ?? a.status.toString().split('.').last;
            return status == _statusFilter;
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Atividades')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<Turma>(
              value: _turmaSelecionada,
              items: minhasTurmas.map((turma) {
                return DropdownMenuItem<Turma>(
                  value: turma,
                  child: Text(turma.nome),
                );
              }).toList(),
              onChanged: (turma) {
                setState(() {
                  _turmaSelecionada = turma;
                });
                _buscarAtividades();
                // Fetch entregas again when turma changes
                if (userId != null) {
                  Provider.of<EntregaAtividadeProvider>(context, listen: false)
                      .fetchEntregasByAluno(userId);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Selecione a Turma',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Todas', null),
                const SizedBox(width: 8),
                _buildFilterChip('Pendentes', 'pendente'),
                const SizedBox(width: 8),
                _buildFilterChip('Entregues', 'entregue'),
                const SizedBox(width: 8),
                _buildFilterChip('Atrasadas', 'atrasado'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAtividades.isEmpty
                    ? const Center(
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
                              'Nenhuma atividade encontrada',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Não há atividades que correspondam aos filtros selecionados',
                              style: TextStyle(
                                color: AppTheme.mutedForegroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAtividades.length,
                        itemBuilder: (context, index) {
                          final atividade = filteredAtividades[index];
                          final entrega =
                              _findEntrega(atividade, userId, entregaProvider);
                          final status = entrega?.status ??
                              atividade.status.toString().split('.').last;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => DetalheAtividadeScreen(
                                        atividade: atividade)));
                              },
                              borderRadius: BorderRadius.circular(16),
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
                                        _buildStatusBadge(status),
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
                                        Row(
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
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Turma: ${_turmaSelecionada?.nome ?? ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme
                                                    .mutedForegroundColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pendente':
        backgroundColor = AppTheme.warningColor.withOpacity(0.2);
        textColor = AppTheme.warningColor;
        label = 'Pendente';
        break;
      case 'entregue':
        backgroundColor = AppTheme.successColor.withOpacity(0.2);
        textColor = AppTheme.successColor;
        label = 'Entregue';
        break;
      case 'atrasado':
        backgroundColor = AppTheme.errorColor.withOpacity(0.2);
        textColor = AppTheme.errorColor;
        label = 'Atrasado';
        break;
      default:
        backgroundColor = AppTheme.mutedColor;
        textColor = AppTheme.mutedForegroundColor;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _statusFilter == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
