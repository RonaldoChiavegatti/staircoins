import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/providers/atividade_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NovaAtividadeScreen extends StatefulWidget {
  const NovaAtividadeScreen({super.key});

  @override
  State<NovaAtividadeScreen> createState() => _NovaAtividadeScreenState();
}

class _NovaAtividadeScreenState extends State<NovaAtividadeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _pontuacaoController = TextEditingController();
  DateTime? _dataEntregaSelecionada;
  Turma? _turmaSelecionada;

  Future<void> _selecionarDataEntrega(BuildContext context) async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 2); // 2 anos à frente
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: lastDate,
    );
    if (picked != null && picked != _dataEntregaSelecionada) {
      setState(() {
        _dataEntregaSelecionada = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_turmaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma turma para a atividade')),
        );
        return;
      }

      try {
        await Provider.of<AtividadeProvider>(context, listen: false)
            .criarAtividade(
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          dataEntrega: _dataEntregaSelecionada!,
          pontuacao: int.parse(_pontuacaoController.text),
          turmaId: _turmaSelecionada!.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade criada com sucesso!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar atividade: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _pontuacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final minhasTurmas = turmaProvider.getMinhasTurmas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Atividade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título da Atividade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título da atividade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição da atividade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pontuacaoController,
                decoration: InputDecoration(
                  labelText: 'Pontuação (StarCoins)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a pontuação';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor, insira um número válido maior que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _dataEntregaSelecionada == null
                      ? 'Selecionar Data de Entrega'
                      : 'Data de Entrega: ${DateFormat('dd/MM/yyyy').format(_dataEntregaSelecionada!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarDataEntrega(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Turma>(
                decoration: InputDecoration(
                  labelText: 'Turma',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _turmaSelecionada,
                hint: const Text('Selecione a Turma'),
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
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione a turma';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Criar Atividade',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
