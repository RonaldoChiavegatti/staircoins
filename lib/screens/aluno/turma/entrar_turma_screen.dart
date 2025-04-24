import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/widgets/gradient_button.dart';

class EntrarTurmaScreen extends StatefulWidget {
  const EntrarTurmaScreen({super.key});

  @override
  State<EntrarTurmaScreen> createState() => _EntrarTurmaScreenState();
}

class _EntrarTurmaScreenState extends State<EntrarTurmaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _entrarTurma() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
      await turmaProvider.entrarTurma(_codigoController.text.trim().toUpperCase());

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
        title: const Text('Entrar em uma Turma'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Entrar em uma Turma',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Digite o código fornecido pelo seu professor para entrar em uma turma',
                style: TextStyle(
                  color: AppTheme.mutedForegroundColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

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
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 2,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código da turma';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão
              GradientButton(
                text: 'Entrar na Turma',
                onPressed: _isLoading ? null : _entrarTurma,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
