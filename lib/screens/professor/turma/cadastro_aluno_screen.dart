import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/widgets/gradient_button.dart';

class CadastroAlunoScreen extends StatefulWidget {
  final List<String>? turmaIdsPreSelecionadas;

  const CadastroAlunoScreen({
    super.key,
    this.turmaIdsPreSelecionadas,
  });

  @override
  State<CadastroAlunoScreen> createState() => _CadastroAlunoScreenState();
}

class _CadastroAlunoScreenState extends State<CadastroAlunoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Turmas selecionadas para o aluno
  final Set<String> _turmasSelecionadas = {};

  @override
  void initState() {
    super.initState();

    // Se houver turmas pré-selecionadas, adicionar à lista
    if (widget.turmaIdsPreSelecionadas != null) {
      _turmasSelecionadas.addAll(widget.turmaIdsPreSelecionadas!);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarAluno() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar se pelo menos uma turma foi selecionada
    if (_turmasSelecionadas.isEmpty) {
      setState(() {
        _errorMessage = 'Selecione pelo menos uma turma para o aluno';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.registerStudent(
        _nomeController.text.trim(),
        _emailController.text.trim(),
        _senhaController.text,
        _turmasSelecionadas.toList(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ?? 'Erro ao cadastrar aluno';
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
    final turmaProvider = Provider.of<TurmaProvider>(context);
    final turmas = turmaProvider.turmasProfessor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Aluno'),
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

              // Nome do aluno
              const Text(
                'Nome do Aluno',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  hintText: 'Digite o nome completo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do aluno';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Digite o email do aluno',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Senha
              const Text(
                'Senha',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _senhaController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Digite uma senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirmar Senha
              const Text(
                'Confirmar Senha',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmaSenhaController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Confirme a senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme a senha';
                  }
                  if (value != _senhaController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Seleção de turmas
              const Text(
                'Turmas',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione as turmas que o aluno participará:',
                style: TextStyle(
                  color: AppTheme.mutedForegroundColor,
                ),
              ),
              const SizedBox(height: 16),

              if (turmas.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Você ainda não tem turmas cadastradas. Crie uma turma primeiro.',
                      style: TextStyle(color: AppTheme.mutedForegroundColor),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turma = turmas[index];
                    final isSelected = _turmasSelecionadas.contains(turma.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        title: Text(turma.nome),
                        subtitle: Text(turma.codigo),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _turmasSelecionadas.add(turma.id);
                            } else {
                              _turmasSelecionadas.remove(turma.id);
                            }
                          });
                        },
                      ),
                    );
                  },
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
                      text: 'Cadastrar Aluno',
                      onPressed: _isLoading ? null : _cadastrarAluno,
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
