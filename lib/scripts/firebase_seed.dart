import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

/// Script para popular o Firebase com dados iniciais para teste
class FirebaseSeed {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  FirebaseSeed({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Executa o script de inicialização completo
  Future<void> seed() async {
    try {
      // Criar usuários de teste
      final professorId = await _criarUsuarioProfessor();
      final alunoId1 = await _criarUsuarioAluno('aluno1@teste.com');
      final alunoId2 = await _criarUsuarioAluno('aluno2@teste.com');
      final alunoId3 = await _criarUsuarioAluno('aluno3@teste.com');
      
      // Criar turmas
      final turma1Id = await _criarTurma(
        professorId: professorId,
        nome: 'Matemática - 9º Ano',
        descricao: 'Turma de matemática do 9º ano do ensino fundamental',
        codigo: 'MAT9A',
      );
      
      final turma2Id = await _criarTurma(
        professorId: professorId,
        nome: 'Ciências - 8º Ano',
        descricao: 'Turma de ciências do 8º ano do ensino fundamental',
        codigo: 'CIE8B',
      );
      
      final turma3Id = await _criarTurma(
        professorId: professorId,
        nome: 'História - 7º Ano',
        descricao: 'Turma de história do 7º ano do ensino fundamental',
        codigo: 'HIS7C',
      );
      
      // Adicionar alunos às turmas
      await _adicionarAlunoTurma(turma1Id, alunoId1);
      await _adicionarAlunoTurma(turma1Id, alunoId2);
      await _adicionarAlunoTurma(turma2Id, alunoId1);
      await _adicionarAlunoTurma(turma2Id, alunoId3);
      await _adicionarAlunoTurma(turma3Id, alunoId2);
      await _adicionarAlunoTurma(turma3Id, alunoId3);
      
      // Adicionar turmas aos alunos
      await _adicionarTurmaUsuario(alunoId1, turma1Id);
      await _adicionarTurmaUsuario(alunoId1, turma2Id);
      await _adicionarTurmaUsuario(alunoId2, turma1Id);
      await _adicionarTurmaUsuario(alunoId2, turma3Id);
      await _adicionarTurmaUsuario(alunoId3, turma2Id);
      await _adicionarTurmaUsuario(alunoId3, turma3Id);
      
      // Criar atividades
      await _criarAtividade(
        turmaId: turma1Id,
        titulo: 'Trabalho de Matemática',
        descricao: 'Resolver os exercícios das páginas 45-48 do livro de matemática. Mostrar todos os cálculos e justificar as respostas.',
        pontuacao: 50,
        dataEntrega: DateTime.now().add(const Duration(days: 7)),
      );
      
      await _criarAtividade(
        turmaId: turma1Id,
        titulo: 'Redação sobre Meio Ambiente',
        descricao: 'Escrever uma redação de 20-30 linhas sobre a importância da preservação do meio ambiente, citando exemplos práticos de como podemos contribuir no dia a dia.',
        pontuacao: 30,
        dataEntrega: DateTime.now().add(const Duration(days: 14)),
      );
      
      await _criarAtividade(
        turmaId: turma2Id,
        titulo: 'Questionário de Ciências',
        descricao: 'Responder ao questionário sobre o Sistema Solar. Pesquisar em fontes confiáveis e citar as referências utilizadas.',
        pontuacao: 20,
        dataEntrega: DateTime.now().add(const Duration(days: 5)),
      );
      
      await _criarAtividade(
        turmaId: turma1Id,
        titulo: 'Apresentação de Matemática',
        descricao: 'Preparar uma apresentação sobre geometria espacial. Incluir exemplos práticos e aplicações no cotidiano.',
        pontuacao: 40,
        dataEntrega: DateTime.now().add(const Duration(days: 10)),
      );
      
      await _criarAtividade(
        turmaId: turma1Id,
        titulo: 'Lista de Exercícios',
        descricao: 'Resolver a lista de exercícios sobre equações do segundo grau. Mostrar o desenvolvimento completo.',
        pontuacao: 25,
        dataEntrega: DateTime.now().add(const Duration(days: 3)),
      );
      
      await _criarAtividade(
        turmaId: turma2Id,
        titulo: 'Experimento de Ciências',
        descricao: 'Realizar um experimento simples sobre fotossíntese e documentar os resultados com fotos.',
        pontuacao: 35,
        dataEntrega: DateTime.now().add(const Duration(days: 12)),
      );
      
      await _criarAtividade(
        turmaId: turma2Id,
        titulo: 'Mapa Conceitual',
        descricao: 'Criar um mapa conceitual sobre o sistema respiratório humano, destacando as principais estruturas e funções.',
        pontuacao: 15,
        dataEntrega: DateTime.now().add(const Duration(days: 8)),
      );
      
      await _criarAtividade(
        turmaId: turma3Id,
        titulo: 'Trabalho sobre Idade Média',
        descricao: 'Pesquisar sobre a vida cotidiana na Europa medieval. Abordar aspectos sociais, econômicos e culturais.',
        pontuacao: 45,
        dataEntrega: DateTime.now().add(const Duration(days: 15)),
      );
      
      await _criarAtividade(
        turmaId: turma3Id,
        titulo: 'Linha do Tempo',
        descricao: 'Criar uma linha do tempo ilustrada com os principais acontecimentos da Revolução Francesa.',
        pontuacao: 30,
        dataEntrega: DateTime.now().add(const Duration(days: 9)),
      );
      
      await _criarAtividade(
        turmaId: turma3Id,
        titulo: 'Análise de Documento Histórico',
        descricao: 'Analisar a Declaração dos Direitos do Homem e do Cidadão e explicar sua importância histórica.',
        pontuacao: 25,
        dataEntrega: DateTime.now().add(const Duration(days: 6)),
      );
      
      // Criar produtos
      await _criarProduto(
        professorId: professorId,
        nome: 'Caneta Personalizada',
        descricao: 'Caneta com o logo da escola, ideal para estudantes que buscam qualidade e estilo.',
        preco: 50,
      );
      
      await _criarProduto(
        professorId: professorId,
        nome: 'Caderno Exclusivo',
        descricao: 'Caderno capa dura com 100 folhas, design exclusivo e papel de alta qualidade.',
        preco: 150,
      );
      
      await _criarProduto(
        professorId: professorId,
        nome: 'Adesivos',
        descricao: 'Conjunto com 10 adesivos temáticos da escola, perfeitos para personalizar seus materiais.',
        preco: 30,
      );
      
      await _criarProduto(
        professorId: professorId,
        nome: 'Squeeze',
        descricao: 'Garrafa de água 500ml, material durável e livre de BPA. Design moderno com o logo da escola.',
        preco: 100,
      );
      
      await _criarProduto(
        professorId: professorId,
        nome: 'Mochila',
        descricao: 'Mochila resistente à água com compartimentos organizados, alças acolchoadas e espaço para laptop.',
        preco: 300,
      );
      
      await _criarProduto(
        professorId: professorId,
        nome: 'Vale Lanche',
        descricao: 'Vale um lanche completo na cantina da escola (sanduíche + suco + sobremesa).',
        preco: 80,
      );
      
      await _criarProduto(
        professorId: professorId,
        nome: 'Certificado de Mérito',
        descricao: 'Certificado de reconhecimento por excelência acadêmica, assinado pelo diretor da escola.',
        preco: 200,
      );
      
      debugPrint('✅ Firebase inicializado com dados de teste!');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Firebase: $e');
      rethrow;
    }
  }

  /// Cria um usuário professor no Firebase Auth e Firestore
  Future<String> _criarUsuarioProfessor() async {
    try {
      // Verificar se o usuário já existe
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: 'professor@teste.com',
          password: 'senha123',
        );
        return userCredential.user!.uid;
      } catch (e) {
        // Usuário não existe, criar novo
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: 'professor@teste.com',
          password: 'senha123',
        );
        
        final user = userCredential.user!;
        await user.updateDisplayName('Professor Teste');
        
        // Criar documento do usuário no Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': 'Professor Teste',
          'email': 'professor@teste.com',
          'tipo': 'professor',
          'turmas': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        return user.uid;
      }
    } catch (e) {
      debugPrint('Erro ao criar usuário professor: $e');
      rethrow;
    }
  }

  /// Cria um usuário aluno no Firebase Auth e Firestore
  Future<String> _criarUsuarioAluno(String email) async {
    try {
      // Verificar se o usuário já existe
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: 'senha123',
        );
        return userCredential.user!.uid;
      } catch (e) {
        // Usuário não existe, criar novo
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: 'senha123',
        );
        
        final user = userCredential.user!;
        String nome;
        if (email == 'aluno1@teste.com') {
          nome = 'Aluno Um';
        } else if (email == 'aluno2@teste.com') {
          nome = 'Aluno Dois';
        } else {
          nome = 'Aluno Três';
        }
        
        await user.updateDisplayName(nome);
        
        // Criar documento do usuário no Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': nome,
          'email': email,
          'tipo': 'aluno',
          'staircoins': 100,
          'turmas': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        return user.uid;
      }
    } catch (e) {
      debugPrint('Erro ao criar usuário aluno: $e');
      rethrow;
    }
  }

  /// Cria uma turma no Firestore
  Future<String> _criarTurma({
    required String professorId,
    required String nome,
    required String descricao,
    required String codigo,
  }) async {
    try {
      // Verificar se já existe uma turma com este código
      final turmasQuery = await _firestore
          .collection('turmas')
          .where('codigo', isEqualTo: codigo)
          .get();
      
      if (turmasQuery.docs.isNotEmpty) {
        return turmasQuery.docs.first.id;
      }
      
      // Criar nova turma
      final turmaRef = await _firestore.collection('turmas').add({
        'nome': nome,
        'descricao': descricao,
        'codigo': codigo,
        'professorId': professorId,
        'alunos': [],
        'atividades': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return turmaRef.id;
    } catch (e) {
      debugPrint('Erro ao criar turma: $e');
      rethrow;
    }
  }

  /// Adiciona um aluno a uma turma
  Future<void> _adicionarAlunoTurma(String turmaId, String alunoId) async {
    try {
      final turmaRef = _firestore.collection('turmas').doc(turmaId);
      final turmaDoc = await turmaRef.get();
      
      if (!turmaDoc.exists) {
        throw Exception('Turma não encontrada');
      }
      
      final alunos = List<String>.from(turmaDoc.data()?['alunos'] ?? []);
      
      if (!alunos.contains(alunoId)) {
        alunos.add(alunoId);
        await turmaRef.update({'alunos': alunos});
      }
    } catch (e) {
      debugPrint('Erro ao adicionar aluno à turma: $e');
      rethrow;
    }
  }

  /// Adiciona uma turma ao usuário
  Future<void> _adicionarTurmaUsuario(String userId, String turmaId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        throw Exception('Usuário não encontrado');
      }
      
      final turmas = List<String>.from(userDoc.data()?['turmas'] ?? []);
      
      if (!turmas.contains(turmaId)) {
        turmas.add(turmaId);
        await userRef.update({'turmas': turmas});
      }
    } catch (e) {
      debugPrint('Erro ao adicionar turma ao usuário: $e');
      rethrow;
    }
  }

  /// Cria uma atividade no Firestore
  Future<String> _criarAtividade({
    required String turmaId,
    required String titulo,
    required String descricao,
    required int pontuacao,
    required DateTime dataEntrega,
  }) async {
    try {
      // Criar atividade
      final atividadeRef = await _firestore.collection('atividades').add({
        'titulo': titulo,
        'descricao': descricao,
        'turmaId': turmaId,
        'pontuacao': pontuacao,
        'dataEntrega': Timestamp.fromDate(dataEntrega),
        'status': 'ativa',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Adicionar atividade à turma
      final turmaRef = _firestore.collection('turmas').doc(turmaId);
      final turmaDoc = await turmaRef.get();
      
      if (!turmaDoc.exists) {
        throw Exception('Turma não encontrada');
      }
      
      final atividades = List<String>.from(turmaDoc.data()?['atividades'] ?? []);
      atividades.add(atividadeRef.id);
      
      await turmaRef.update({'atividades': atividades});
      
      return atividadeRef.id;
    } catch (e) {
      debugPrint('Erro ao criar atividade: $e');
      rethrow;
    }
  }

  /// Cria um produto no Firestore
  Future<String> _criarProduto({
    required String professorId,
    required String nome,
    required String descricao,
    required int preco,
  }) async {
    try {
      // Verificar se já existe um produto com este nome
      final produtosQuery = await _firestore
          .collection('produtos')
          .where('nome', isEqualTo: nome)
          .where('professorId', isEqualTo: professorId)
          .get();
      
      if (produtosQuery.docs.isNotEmpty) {
        return produtosQuery.docs.first.id;
      }
      
      // Criar novo produto
      final produtoRef = await _firestore.collection('produtos').add({
        'nome': nome,
        'descricao': descricao,
        'preco': preco,
        'disponivel': true,
        'professorId': professorId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return produtoRef.id;
    } catch (e) {
      debugPrint('Erro ao criar produto: $e');
      rethrow;
    }
  }
} 