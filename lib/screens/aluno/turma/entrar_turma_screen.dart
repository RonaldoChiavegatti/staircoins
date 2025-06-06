import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/widgets/gradient_button.dart';
import 'package:staircoins/providers/auth_provider.dart';

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
      final resultado = await turmaProvider
          .entrarTurma(_codigoController.text.trim().toUpperCase());

      if (!mounted) return;

      if (resultado) {
        // Recarregar as turmas do usuário para garantir que a nova turma apareça
        await turmaProvider.recarregarTurmas();

        // Buscar especificamente as turmas do usuário atual
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user != null && authProvider.user!.turmas.isNotEmpty) {
          await turmaProvider.buscarTurmasPorIds(authProvider.user!.turmas);

          // Usar o método de atualização forçada para garantir que todas as turmas sejam carregadas
          debugPrint(
              'EntrarTurmaScreen: Iniciando atualização forçada das turmas');
          await turmaProvider.forcarAtualizacaoTurmasAluno();
        }

        debugPrint(
            'EntrarTurmaScreen: Turma adicionada com sucesso, turmas recarregadas');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você entrou na turma com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context)
            .pop(true); // Retornar true para indicar que entrou na turma
      } else {
        setState(() {
          _errorMessage =
              turmaProvider.errorMessage ?? 'Erro ao entrar na turma';
        });
      }
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  size: 64,
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Digite o código fornecido pelo seu professor para entrar em uma turma',
                  style: TextStyle(
                    color: AppTheme.mutedForegroundColor,
                  ),
                  textAlign: TextAlign.center,
                ),
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

              // Código da turma
              const Text(
                'Código da Turma',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // Campo de código com estilo destacado
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: MAT9A',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    prefixIcon: Icon(
                      Icons.tag,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o código da turma';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'O código da turma geralmente contém letras e números, e é fornecido pelo seu professor',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForegroundColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Botão
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GradientButton(
                  text: 'Entrar na Turma',
                  onPressed: _isLoading ? null : _entrarTurma,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
