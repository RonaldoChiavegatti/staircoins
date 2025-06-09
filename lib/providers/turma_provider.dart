import 'package:flutter/material.dart';
import 'package:staircoins/domain/repositories/turma_repository.dart';
import 'package:staircoins/models/turma.dart';
import 'package:staircoins/models/user.dart';
import 'package:staircoins/providers/auth_provider.dart';
import 'package:staircoins/core/di/injection_container.dart' as di;

class TurmaProvider with ChangeNotifier {
  final TurmaRepository turmaRepository;
  late final AuthProvider authProvider;

  List<Turma> _turmas = [];
  bool _isLoading = false;
  String? _errorMessage;

  TurmaProvider({
    required this.turmaRepository,
  }) {
    authProvider = di.sl<AuthProvider>();
    // Não carregamos as turmas aqui para evitar carregamento prematuro
    // O carregamento será feito quando o usuário estiver autenticado
  }

  List<Turma> get turmas => _turmas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método para limpar os dados quando o usuário fizer logout
  void limparDados() {
    debugPrint('TurmaProvider: Limpando dados após logout');
    _turmas = [];
    _errorMessage = null;

    // Garantir que todos os listeners sejam notificados
    notifyListeners();

    debugPrint('TurmaProvider: Dados limpos com sucesso');
  }

  // Método para inicializar o provider quando o usuário fizer login
  Future<void> init() async {
    // Limpar dados anteriores para evitar mistura de dados
    _turmas = [];
    _errorMessage = null;

    try {
      if (authProvider.isAuthenticated) {
        final user = authProvider.user;
        debugPrint(
            'TurmaProvider.init: Usuário autenticado: ${user?.nome} (${user?.id})');

        if (user != null && user.turmas.isNotEmpty) {
          debugPrint(
              'TurmaProvider.init: Usuário tem ${user.turmas.length} turmas associadas: ${user.turmas}');
          // Buscar turmas pelos IDs associados ao usuário
          await buscarTurmasPorIds(user.turmas);
        } else {
          debugPrint(
              'TurmaProvider.init: Usuário não tem turmas ou turmas é null, carregando pelo método tradicional');
          await _loadTurmas();
        }
      } else {
        debugPrint('TurmaProvider.init: Usuário não autenticado');
      }
    } catch (e) {
      debugPrint('TurmaProvider.init: Erro ao inicializar: $e');
      _errorMessage = 'Erro ao carregar turmas: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadTurmas() async {
    if (authProvider.user == null) {
      debugPrint(
          'TurmaProvider: Usuário não autenticado, não carregando turmas');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = authProvider.user!;
      debugPrint(
          'TurmaProvider: Carregando turmas para o usuário: ${user.id} (${user.name})');
      debugPrint(
          'TurmaProvider: Tipo de usuário: ${authProvider.isProfessor ? 'Professor' : 'Aluno'}');

      // Limpar lista de turmas atual antes de carregar novas
      _turmas = [];

      // Verificar se o usuário tem turmas associadas
      if (user.turmas.isNotEmpty) {
        debugPrint(
            'TurmaProvider: Usuário tem ${user.turmas.length} turmas associadas: ${user.turmas}');

        // Mapa para armazenar turmas únicas por ID
        final turmasUnicas = <String, Turma>{};

        // Carregar cada turma pelo ID
        for (final turmaId in user.turmas) {
          debugPrint('TurmaProvider: Carregando turma com ID: $turmaId');
          try {
            final result = await turmaRepository.buscarTurmaPorId(turmaId);
            result.fold(
              (failure) {
                debugPrint(
                    'TurmaProvider: Erro ao carregar turma $turmaId: ${failure.message}');
              },
              (turma) {
                debugPrint(
                    'TurmaProvider: Turma carregada: ${turma.id} - ${turma.nome} - ${turma.codigo}');
                turmasUnicas[turma.id] = turma;
              },
            );
          } catch (e) {
            debugPrint('TurmaProvider: Erro ao carregar turma $turmaId: $e');
          }
        }

        // Converter o mapa em lista
        _turmas = turmasUnicas.values.toList();
        debugPrint(
            'TurmaProvider: Total de turmas carregadas: ${_turmas.length}');
      } else {
        // Método tradicional (para compatibilidade)
        if (authProvider.isProfessor) {
          final result =
              await turmaRepository.listarTurmasPorProfessor(user.id);
          result.fold(
            (failure) {
              _errorMessage = failure.message;
              debugPrint(
                  'TurmaProvider: Erro ao carregar turmas: ${failure.message}');
            },
            (turmas) {
              // Remover duplicatas
              final turmasUnicas = <String, Turma>{};
              for (var turma in turmas) {
                turmasUnicas[turma.id] = turma;
              }

              _turmas = turmasUnicas.values.toList();
              debugPrint(
                  'TurmaProvider: Turmas carregadas com sucesso: ${_turmas.length}');
            },
          );
        } else {
          final result = await turmaRepository.listarTurmasPorAluno(user.id);
          result.fold(
            (failure) => _errorMessage = failure.message,
            (turmas) {
              // Remover duplicatas
              final turmasUnicas = <String, Turma>{};
              for (var turma in turmas) {
                turmasUnicas[turma.id] = turma;
              }

              _turmas = turmasUnicas.values.toList();
            },
          );
        }
      }
    } catch (e) {
      debugPrint('TurmaProvider: Erro ao carregar turmas: $e');
      _errorMessage = 'Erro ao carregar turmas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Turma> getMinhasTurmas() {
    final user = authProvider.user;
    if (user == null) return [];

    if (authProvider.isProfessor) {
      return getTurmasProfessor();
    } else {
      return getTurmasAluno();
    }
  }

  List<Turma> getTurmasProfessor() {
    final user = authProvider.user;
    if (user == null || user.type != UserType.professor) return [];

    // Filtrar turmas do professor e remover duplicatas por ID
    final turmasProfessor =
        _turmas.where((turma) => turma.professorId == user.id).toList();

    // Remover duplicatas
    final turmasUnicas = <String, Turma>{};
    for (var turma in turmasProfessor) {
      turmasUnicas[turma.id] = turma;
    }

    debugPrint(
        'TurmaProvider.getTurmasProfessor: Total de turmas: ${turmasUnicas.length}');
    return turmasUnicas.values.toList();
  }

  List<Turma> getTurmasAluno() {
    final user = authProvider.user;
    if (user == null || user.type != UserType.aluno) return [];

    // Verificar se temos as turmas do aluno carregadas
    final turmasDoUsuario = user.turmas;
    if (turmasDoUsuario.isEmpty) {
      debugPrint(
          'TurmaProvider.getTurmasAluno: Usuário não tem turmas associadas');
      return [];
    }

    // Mapa para armazenar turmas únicas
    final turmasUnicas = <String, Turma>{};

    // Primeiro, verificar turmas onde o aluno está na lista de alunos
    for (var turma in _turmas) {
      if (turma.alunos.contains(user.id)) {
        turmasUnicas[turma.id] = turma;
        debugPrint(
            'TurmaProvider.getTurmasAluno: Encontrada turma pelo ID do aluno na lista de alunos: ${turma.id} - ${turma.nome}');
      }
    }

    // Segundo, verificar turmas pelos IDs associados ao usuário
    for (var turma in _turmas) {
      if (turmasDoUsuario.contains(turma.id)) {
        turmasUnicas[turma.id] = turma;
        debugPrint(
            'TurmaProvider.getTurmasAluno: Encontrada turma pelo ID na lista do usuário: ${turma.id} - ${turma.nome}');
      }
    }

    // Verificar se temos todas as turmas carregadas
    debugPrint(
        'TurmaProvider.getTurmasAluno: Total de turmas carregadas: ${_turmas.length}');
    debugPrint(
        'TurmaProvider.getTurmasAluno: IDs das turmas do usuário: $turmasDoUsuario');

    // Listar todas as turmas carregadas para debug
    for (var turma in _turmas) {
      debugPrint(
          'TurmaProvider.getTurmasAluno: Turma carregada: ${turma.id} - ${turma.nome} - Alunos: ${turma.alunos}');
    }

    // Se não encontrou nenhuma turma, mas temos turmas carregadas, verificar se alguma turma corresponde aos IDs
    if (turmasUnicas.isEmpty &&
        _turmas.isNotEmpty &&
        turmasDoUsuario.isNotEmpty) {
      debugPrint(
          'TurmaProvider.getTurmasAluno: Nenhuma turma encontrada pelos métodos normais, tentando buscar por ID direto');

      // Último recurso: retornar qualquer turma que corresponda aos IDs, mesmo que o aluno não esteja na lista
      for (var turmaId in turmasDoUsuario) {
        final turma = _turmas.firstWhere(
          (t) => t.id == turmaId,
          orElse: () => Turma(
            id: '',
            nome: '',
            descricao: '',
            professorId: '',
            alunos: [],
            codigo: '',
          ),
        );

        if (turma.id.isNotEmpty) {
          turmasUnicas[turma.id] = turma;
          debugPrint(
              'TurmaProvider.getTurmasAluno: Encontrada turma por correspondência direta de ID: ${turma.id} - ${turma.nome}');
        }
      }
    }

    final resultado = turmasUnicas.values.toList();
    debugPrint(
        'TurmaProvider.getTurmasAluno: Total de turmas encontradas: ${resultado.length}');

    // Verificar se todas as turmas do usuário foram encontradas
    if (resultado.length < turmasDoUsuario.length) {
      final turmasEncontradasIds = resultado.map((t) => t.id).toSet();
      final turmasFaltando = turmasDoUsuario
          .where((id) => !turmasEncontradasIds.contains(id))
          .toList();
      debugPrint(
          'TurmaProvider.getTurmasAluno: Faltam carregar turmas: $turmasFaltando');
    }

    return resultado;
  }

  Future<bool> adicionarTurma(
      String nome, String descricao, String codigo) async {
    final user = authProvider.user;
    if (user == null || user.type != UserType.professor) {
      _errorMessage = 'Apenas professores podem criar turmas';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('TurmaProvider: Criando nova turma: $nome ($codigo)');

      // Criar nova turma
      final novaTurma = Turma(
        id: '', // ID será gerado pelo Firestore
        nome: nome,
        descricao: descricao,
        codigo: codigo.toUpperCase(),
        professorId: user.id,
        alunos: [],
      );

      final result = await turmaRepository.criarTurma(novaTurma);

      return await result.fold((failure) {
        _errorMessage = failure.message;
        debugPrint('TurmaProvider: Erro ao criar turma: ${failure.message}');
        return false;
      }, (turma) async {
        debugPrint(
            'TurmaProvider: Turma criada com sucesso: ${turma.id} - ${turma.nome}');

        // Adicionar a turma à lista local
        _turmas.add(turma);

        // Adicionar o ID da turma ao usuário
        debugPrint(
            'TurmaProvider: Adicionando turma ${turma.id} ao usuário ${user.id}');

        // Criar uma nova lista de turmas incluindo a nova
        final turmasAtualizadas = List<String>.from(user.turmas);
        turmasAtualizadas.add(turma.id);

        // Atualizar o usuário com a nova lista de turmas
        final updatedUser = user.copyWith(turmas: turmasAtualizadas);
        final success = await authProvider.updateUser(updatedUser);

        if (success) {
          debugPrint('TurmaProvider: Turma adicionada ao usuário com sucesso');
        } else {
          debugPrint('TurmaProvider: Erro ao adicionar turma ao usuário');
        }

        notifyListeners();
        return true;
      });
    } catch (e) {
      debugPrint('TurmaProvider: Erro ao criar turma: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> entrarTurma(String codigo) async {
    final user = authProvider.user;
    if (user == null || user.type != UserType.aluno) {
      _errorMessage = 'Apenas alunos podem entrar em turmas';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
          'TurmaProvider.entrarTurma: Tentando entrar na turma com código: $codigo');

      // Busca a turma pelo código
      final turmaPorCodigoResult =
          await turmaRepository.buscarTurmaPorCodigo(codigo);

      return await turmaPorCodigoResult.fold((failure) {
        _errorMessage = failure.message;
        debugPrint(
            'TurmaProvider.entrarTurma: Erro ao buscar turma: ${failure.message}');
        return false;
      }, (turma) async {
        // Verifica se o aluno já está na turma
        if (turma.alunos.contains(user.id)) {
          _errorMessage = 'Você já está nesta turma';
          debugPrint('TurmaProvider.entrarTurma: Aluno já está na turma');
          return false;
        }

        debugPrint(
            'TurmaProvider.entrarTurma: Adicionando aluno ${user.id} à turma ${turma.id}');

        // Adicionar aluno à turma
        final adicionarAlunoResult =
            await turmaRepository.adicionarAlunoTurma(turma.id, user.id);

        return await adicionarAlunoResult.fold((failure) {
          _errorMessage = failure.message;
          debugPrint(
              'TurmaProvider.entrarTurma: Erro ao adicionar aluno à turma: ${failure.message}');
          return false;
        }, (turmaNova) async {
          debugPrint(
              'TurmaProvider.entrarTurma: Aluno adicionado à turma com sucesso');

          // Adicionar turma ao aluno
          final addTurmaToUserResult =
              await authProvider.addTurmaToUser(turma.id);

          if (addTurmaToUserResult) {
            debugPrint(
                'TurmaProvider.entrarTurma: Turma adicionada ao usuário com sucesso');

            // Atualiza a lista local
            final index = _turmas.indexWhere((t) => t.id == turma.id);
            if (index >= 0) {
              _turmas[index] = turmaNova;
              debugPrint(
                  'TurmaProvider.entrarTurma: Turma atualizada na lista local');
            } else {
              _turmas.add(turmaNova);
              debugPrint(
                  'TurmaProvider.entrarTurma: Turma adicionada à lista local');
            }

            // Verificar se a turma está na lista local após a adição
            final turmaAdicionada = _turmas.any((t) => t.id == turma.id);
            debugPrint(
                'TurmaProvider.entrarTurma: Turma está na lista local? $turmaAdicionada');

            // Verificar se o usuário tem a turma associada
            final userTurmas = authProvider.user?.turmas ?? [];
            final turmaAssociada = userTurmas.contains(turma.id);
            debugPrint(
                'TurmaProvider.entrarTurma: Turma está associada ao usuário? $turmaAssociada (${userTurmas.length} turmas)');

            notifyListeners();
            return true;
          } else {
            _errorMessage = 'Erro ao adicionar turma ao usuário';
            debugPrint(
                'TurmaProvider.entrarTurma: Erro ao adicionar turma ao usuário');
            return false;
          }
        });
      });
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('TurmaProvider.entrarTurma: Exceção: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Turma? getTurmaById(String id) {
    try {
      return _turmas.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Turma> get turmasProfessor {
    final user = authProvider.user;
    if (user == null || user.type != UserType.professor) return [];

    return _turmas.where((t) => t.professorId == user.id).toList();
  }

  // Recarregar turmas
  Future<void> recarregarTurmas() async {
    debugPrint('TurmaProvider.recarregarTurmas: Recarregando turmas...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = authProvider.user;
      if (user == null) {
        debugPrint('TurmaProvider.recarregarTurmas: Usuário não autenticado');
        return;
      }

      debugPrint(
          'TurmaProvider.recarregarTurmas: Usuário: ${user.id} (${user.name})');
      debugPrint(
          'TurmaProvider.recarregarTurmas: Tipo de usuário: ${user.type}');
      debugPrint(
          'TurmaProvider.recarregarTurmas: Turmas do usuário: ${user.turmas}');

      // Verificar se o usuário tem turmas associadas
      if (user.turmas.isNotEmpty) {
        debugPrint(
            'TurmaProvider.recarregarTurmas: Usuário tem ${user.turmas.length} turmas associadas');

        // Não limpar a lista existente, buscarTurmasPorIds já preserva as turmas existentes
        await buscarTurmasPorIds(user.turmas);
      } else {
        // Método tradicional (para compatibilidade)
        if (user.type == UserType.professor) {
          debugPrint(
              'TurmaProvider.recarregarTurmas: Carregando turmas do professor');
          final result =
              await turmaRepository.listarTurmasPorProfessor(user.id);
          result.fold(
            (failure) {
              _errorMessage = failure.message;
              debugPrint(
                  'TurmaProvider.recarregarTurmas: Erro ao carregar turmas: ${failure.message}');
            },
            (turmas) {
              // Preservar turmas existentes
              final turmasUnicas = <String, Turma>{};

              // Primeiro, adicionar turmas existentes
              for (var turma in _turmas) {
                turmasUnicas[turma.id] = turma;
              }

              // Depois, adicionar ou atualizar com as novas turmas
              for (var turma in turmas) {
                turmasUnicas[turma.id] = turma;
              }

              _turmas = turmasUnicas.values.toList();
              debugPrint(
                  'TurmaProvider.recarregarTurmas: Turmas carregadas com sucesso: ${_turmas.length}');

              // Verificar se o usuário tem estas turmas associadas
              final turmasIds = _turmas.map((t) => t.id).toList();
              final turmasNaoAssociadas =
                  turmasIds.where((id) => !user.turmas.contains(id)).toList();

              if (turmasNaoAssociadas.isNotEmpty) {
                debugPrint(
                    'TurmaProvider.recarregarTurmas: Encontradas ${turmasNaoAssociadas.length} turmas não associadas ao usuário');

                // Atualizar o usuário com todas as turmas
                final todasTurmas = {...user.turmas, ...turmasIds}.toList();
                final updatedUser = user.copyWith(turmas: todasTurmas);
                authProvider.updateUser(updatedUser).then((success) {
                  if (success) {
                    debugPrint(
                        'TurmaProvider.recarregarTurmas: Usuário atualizado com todas as turmas');
                  } else {
                    debugPrint(
                        'TurmaProvider.recarregarTurmas: Erro ao atualizar usuário com todas as turmas');
                  }
                });
              }
            },
          );
        } else {
          debugPrint(
              'TurmaProvider.recarregarTurmas: Carregando turmas do aluno');
          final result = await turmaRepository.listarTurmasPorAluno(user.id);
          result.fold(
            (failure) {
              _errorMessage = failure.message;
              debugPrint(
                  'TurmaProvider.recarregarTurmas: Erro ao carregar turmas: ${failure.message}');
            },
            (turmas) {
              // Preservar turmas existentes
              final turmasUnicas = <String, Turma>{};

              // Primeiro, adicionar turmas existentes
              for (var turma in _turmas) {
                turmasUnicas[turma.id] = turma;
              }

              // Depois, adicionar ou atualizar com as novas turmas
              for (var turma in turmas) {
                turmasUnicas[turma.id] = turma;
              }

              _turmas = turmasUnicas.values.toList();
              debugPrint(
                  'TurmaProvider.recarregarTurmas: Turmas carregadas com sucesso: ${_turmas.length}');

              // Verificar se o usuário tem estas turmas associadas
              final turmasIds = _turmas.map((t) => t.id).toList();
              final turmasNaoAssociadas =
                  turmasIds.where((id) => !user.turmas.contains(id)).toList();

              if (turmasNaoAssociadas.isNotEmpty) {
                debugPrint(
                    'TurmaProvider.recarregarTurmas: Encontradas ${turmasNaoAssociadas.length} turmas não associadas ao usuário');

                // Atualizar o usuário com todas as turmas
                final todasTurmas = {...user.turmas, ...turmasIds}.toList();
                final updatedUser = user.copyWith(turmas: todasTurmas);
                authProvider.updateUser(updatedUser).then((success) {
                  if (success) {
                    debugPrint(
                        'TurmaProvider.recarregarTurmas: Usuário atualizado com todas as turmas');
                  } else {
                    debugPrint(
                        'TurmaProvider.recarregarTurmas: Erro ao atualizar usuário com todas as turmas');
                  }
                });
              }
            },
          );
        }
      }

      // Verificar o resultado final
      debugPrint(
          'TurmaProvider.recarregarTurmas: Total de turmas carregadas: ${_turmas.length}');
      for (var turma in _turmas) {
        debugPrint(
            'TurmaProvider.recarregarTurmas: Turma: ${turma.id} - ${turma.nome} - ${turma.codigo}');
      }
    } catch (e) {
      debugPrint('TurmaProvider.recarregarTurmas: Erro ao carregar turmas: $e');
      _errorMessage = 'Erro ao carregar turmas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para buscar turmas por IDs específicos
  Future<void> buscarTurmasPorIds(List<String> turmaIds) async {
    if (turmaIds.isEmpty) {
      debugPrint('TurmaProvider: Lista de IDs vazia, não buscando turmas');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
          'TurmaProvider: Buscando ${turmaIds.length} turmas por IDs: $turmaIds');

      // Mapa para armazenar turmas únicas por ID (incluindo as existentes)
      final turmasUnicas = <String, Turma>{};

      // Primeiro, preservar as turmas existentes
      for (var turma in _turmas) {
        turmasUnicas[turma.id] = turma;
      }

      // Filtrar apenas os IDs que não estão na lista atual
      final turmasExistentesIds = _turmas.map((t) => t.id).toSet();
      final turmasParaBuscar =
          turmaIds.where((id) => !turmasExistentesIds.contains(id)).toList();

      if (turmasParaBuscar.isEmpty) {
        debugPrint(
            'TurmaProvider: Todas as turmas já estão carregadas localmente');
      } else {
        debugPrint(
            'TurmaProvider: Buscando ${turmasParaBuscar.length} turmas novas');

        // Buscar cada turma pelo ID
        for (final turmaId in turmasParaBuscar) {
          try {
            final result = await turmaRepository.buscarTurmaPorId(turmaId);
            result.fold(
              (failure) {
                debugPrint(
                    'TurmaProvider: Erro ao buscar turma $turmaId: ${failure.message}');
              },
              (turma) {
                debugPrint(
                    'TurmaProvider: Turma encontrada: ${turma.id} - ${turma.nome}');
                turmasUnicas[turma.id] = turma;
              },
            );
          } catch (e) {
            debugPrint('TurmaProvider: Erro ao buscar turma $turmaId: $e');
          }
        }
      }

      // Atualizar a lista de turmas
      _turmas = turmasUnicas.values.toList();
      debugPrint(
          'TurmaProvider: Total de turmas após busca: ${_turmas.length}');

      // Verificar turmas que não foram encontradas
      final turmasEncontradasIds = _turmas.map((t) => t.id).toSet();
      final turmasNaoEncontradas =
          turmaIds.where((id) => !turmasEncontradasIds.contains(id)).toList();

      if (turmasNaoEncontradas.isNotEmpty) {
        debugPrint(
            'TurmaProvider: Algumas turmas não foram encontradas: $turmasNaoEncontradas');
      }
    } catch (e) {
      debugPrint('TurmaProvider: Erro ao buscar turmas: $e');
      _errorMessage = 'Erro ao buscar turmas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona uma turma à lista local sem salvá-la no Firebase
  void adicionarTurmaLocal(Turma turma) {
    debugPrint(
        'TurmaProvider: Adicionando turma local: ${turma.id} - ${turma.nome}');

    // Verificar se a turma já existe na lista
    if (!_turmas.any((t) => t.id == turma.id)) {
      _turmas.add(turma);
      notifyListeners();
    }
  }

  // Método especial para depuração e correção de problemas de sincronização
  Future<void> forcarAtualizacaoTurmasAluno() async {
    final user = authProvider.user;
    if (user == null || user.type != UserType.aluno || user.turmas.isEmpty) {
      debugPrint(
          'TurmaProvider.forcarAtualizacaoTurmasAluno: Usuário inválido ou sem turmas');
      return;
    }

    debugPrint(
        'TurmaProvider.forcarAtualizacaoTurmasAluno: Iniciando atualização forçada para ${user.turmas.length} turmas');

    // Lista para armazenar turmas encontradas
    final turmasEncontradas = <Turma>[];

    // Buscar cada turma individualmente
    for (final turmaId in user.turmas) {
      try {
        debugPrint(
            'TurmaProvider.forcarAtualizacaoTurmasAluno: Buscando turma $turmaId');
        final result = await turmaRepository.buscarTurmaPorId(turmaId);

        await result.fold((failure) {
          debugPrint(
              'TurmaProvider.forcarAtualizacaoTurmasAluno: Erro ao buscar turma $turmaId: ${failure.message}');
        }, (turma) async {
          debugPrint(
              'TurmaProvider.forcarAtualizacaoTurmasAluno: Turma encontrada: ${turma.id} - ${turma.nome}');

          // Verificar se o aluno está na lista de alunos da turma
          if (!turma.alunos.contains(user.id)) {
            debugPrint(
                'TurmaProvider.forcarAtualizacaoTurmasAluno: Aluno não está na lista de alunos da turma, adicionando...');

            // Adicionar aluno à turma
            final alunoAdicionadoResult =
                await turmaRepository.adicionarAlunoTurma(turma.id, user.id);
            await alunoAdicionadoResult.fold((failure) {
              debugPrint(
                  'TurmaProvider.forcarAtualizacaoTurmasAluno: Erro ao adicionar aluno à turma: ${failure.message}');
            }, (turmaNova) {
              debugPrint(
                  'TurmaProvider.forcarAtualizacaoTurmasAluno: Aluno adicionado à turma com sucesso');
              turmasEncontradas.add(turmaNova);
            });
          } else {
            turmasEncontradas.add(turma);
          }
        });
      } catch (e) {
        debugPrint(
            'TurmaProvider.forcarAtualizacaoTurmasAluno: Erro ao processar turma $turmaId: $e');
      }
    }

    // Atualizar a lista local com as turmas encontradas
    for (var turma in turmasEncontradas) {
      final index = _turmas.indexWhere((t) => t.id == turma.id);
      if (index >= 0) {
        _turmas[index] = turma;
        debugPrint(
            'TurmaProvider.forcarAtualizacaoTurmasAluno: Turma atualizada na lista local: ${turma.id}');
      } else {
        _turmas.add(turma);
        debugPrint(
            'TurmaProvider.forcarAtualizacaoTurmasAluno: Turma adicionada à lista local: ${turma.id}');
      }
    }

    // Notificar sobre as mudanças
    notifyListeners();

    // Verificar resultado final
    final turmasAluno = getTurmasAluno();
    debugPrint(
        'TurmaProvider.forcarAtualizacaoTurmasAluno: Total de turmas do aluno após atualização: ${turmasAluno.length}');
  }
}
