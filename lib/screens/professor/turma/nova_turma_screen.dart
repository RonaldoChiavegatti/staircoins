import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/widgets/gradient_button.dart';

class NovaTurmaScreen extends StatefulWidget {
  const NovaTurmaScreen({super.key});

  @override
  State<NovaTurmaScreen> createState() => _NovaTurmaScreenState();
}

class _NovaTurmaScreenState extends State<NovaTurmaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _codigoController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _criarTurma() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
      await turmaProvider.adicionarTurma(
        _nomeController.text.trim(),
        _descricaoController.text.trim(),
        _codigoController.text.trim().toUpperCase(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Turma'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensagem de erro
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Nome da turma
              const Text(
                'Nome da Turma',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Matemática - 9º Ano',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da turma';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Descrição
              const Text(
                'Descrição',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  hintText: 'Descreva a turma...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Código da turma
              const Text(
                'Código da Turma',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  hintText: 'Ex: MAT9A',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código da turma';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Este código será usado pelos alunos para entrar na turma',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForegroundColor,
                ),
              ),
              const SizedBox(height: 32),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
                      text: 'Criar Turma',
                      onPressed: _isLoading ? null : _criarTurma,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
