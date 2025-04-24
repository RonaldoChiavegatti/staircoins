import 'package:flutter/material.dart';
import 'package:staircoins/theme/app_theme.dart';

class AlunoAtividadesScreen extends StatefulWidget {
  const AlunoAtividadesScreen({super.key});

  @override
  State<AlunoAtividadesScreen> createState() => _AlunoAtividadesScreenState();
}

class _AlunoAtividadesScreenState extends State<AlunoAtividadesScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    // Dados mockados para demonstração
    final atividades = [
      {
        'id': '1',
        'titulo': 'Trabalho de Matemática',
        'dataEntrega': '2023-05-15',
        'pontuacao': 50,
        'status': 'pendente',
        'turma': 'Matemática - 9º Ano',
      },
      {
        'id': '2',
        'titulo': 'Redação sobre Meio Ambiente',
        'dataEntrega': '2023-05-20',
        'pontuacao': 30,
        'status': 'pendente',
        'turma': 'Matemática - 9º Ano',
      },
      {
        'id': '3',
        'titulo': 'Questionário de História',
        'dataEntrega': '2023-05-10',
        'pontuacao': 20,
        'status': 'entregue',
        'turma': 'História - 8º Ano',
      },
      {
        'id': '4',
        'titulo': 'Apresentação de Ciências',
        'dataEntrega': '2023-04-30',
        'pontuacao': 40,
        'status': 'atrasado',
        'turma': 'Matemática - 9º Ano',
      },
    ];

    // Filtra atividades com base no status
    final filteredAtividades = _statusFilter == null
        ? atividades
        : atividades.where((a) => a['status'] == _statusFilter).toList();

    return Scaffold(
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar atividades...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // TODO: Implementar busca
              },
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

          // Lista de atividades
          Expanded(
            child: filteredAtividades.isEmpty
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
                          'Nenhuma atividade encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            // TODO: Implementar detalhes da atividade
                          },
                          borderRadius: BorderRadius.circular(16),
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
                                    _buildStatusBadge(atividade['status'] as String),
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
                                    Row(
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
                                        const SizedBox(width: 8),
                                        Text(
                                          'Turma: ${atividade['turma']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.mutedForegroundColor,
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
