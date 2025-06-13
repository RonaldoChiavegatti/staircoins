import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staircoins/providers/produto_provider.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/providers/turma_provider.dart';
import 'package:staircoins/theme/app_theme.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/models/turma.dart';

class CadastroProdutoScreen extends StatefulWidget {
  final Produto? produto;
  const CadastroProdutoScreen({super.key, this.produto});

  @override
  State<CadastroProdutoScreen> createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _pesoTamanhoController = TextEditingController();

  String? _selectedTurmaId;
  List<Turma> _turmasProfessor = [];
  bool _isLoadingTurmas = false;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      _nomeController.text = widget.produto!.nome;
      _descricaoController.text = widget.produto!.descricao;
      _precoController.text = widget.produto!.preco.toString();
      _quantidadeController.text = widget.produto!.quantidade.toString();
      _pesoTamanhoController.text = widget.produto!.pesoTamanho ?? '';
      _selectedTurmaId = widget.produto!.turmaId;
    }

    // Carregar turmas do professor
    _carregarTurmas();
  }

  Future<void> _carregarTurmas() async {
    setState(() {
      _isLoadingTurmas = true;
    });

    try {
      final turmaProvider = Provider.of<TurmaProvider>(context, listen: false);
      await turmaProvider.init();
      final turmas = turmaProvider.getTurmasProfessor();

      setState(() {
        _turmasProfessor = turmas;
        _isLoadingTurmas = false;

        // Se existir mais de uma turma e não tiver turma selecionada,
        // seleciona a primeira por padrão
        if (_selectedTurmaId == null && _turmasProfessor.isNotEmpty) {
          _selectedTurmaId = _turmasProfessor.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingTurmas = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar turmas: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    _pesoTamanhoController.dispose();
    super.dispose();
  }

  void _salvarProduto() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Verificar se o professor selecionou uma turma
      if (_selectedTurmaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma turma')),
        );
        return;
      }

      try {
        // Obter ID do professor atual
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final professorId = authProvider.user?.id;

        if (professorId == null) {
          throw Exception('Não foi possível identificar o professor');
        }

        if (widget.produto == null) {
          await Provider.of<ProdutoProvider>(context, listen: false)
              .adicionarProduto(
            nome: _nomeController.text,
            descricao: _descricaoController.text,
            preco: int.parse(_precoController.text),
            quantidade: int.parse(_quantidadeController.text),
            pesoTamanho: _pesoTamanhoController.text,
            professorId: professorId,
            turmaId: _selectedTurmaId!,
          );
        } else {
          final produtoEditado = widget.produto!.copyWith(
            nome: _nomeController.text,
            descricao: _descricaoController.text,
            preco: int.parse(_precoController.text),
            quantidade: int.parse(_quantidadeController.text),
            pesoTamanho: _pesoTamanhoController.text,
            professorId: professorId,
            turmaId: _selectedTurmaId!,
          );
          await Provider.of<ProdutoProvider>(context, listen: false)
              .editarProduto(produtoEditado);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto salvo com sucesso!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do produto';
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
                    return 'Por favor, insira a descrição do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: InputDecoration(
                  labelText: 'Preço (em coins)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço do produto';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor, insira um preço válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade do produto';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Por favor, insira uma quantidade válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pesoTamanhoController,
                decoration: InputDecoration(
                  labelText: 'Peso/Tamanho',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o peso ou tamanho do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown para seleção de turma
              _isLoadingTurmas
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Selecione a Turma',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _selectedTurmaId,
                      items: _turmasProfessor.map((turma) {
                        return DropdownMenuItem<String>(
                          value: turma.id,
                          child: Text(turma.nome),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTurmaId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione uma turma';
                        }
                        return null;
                      },
                    ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: Provider.of<ProdutoProvider>(context).isLoading
                    ? null
                    : _salvarProduto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Provider.of<ProdutoProvider>(context).isLoading
                    ? const CircularProgressIndicator(
                        color: AppTheme.backgroundColor,
                      )
                    : const Text(
                        'Salvar Produto',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
