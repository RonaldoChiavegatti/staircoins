import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/models/troca_produto.dart';

class FirebaseProdutoDatasource {
  final FirebaseFirestore firestore;
  FirebaseProdutoDatasource(this.firestore);

  CollectionReference get produtosRef => firestore.collection('produtos');
  CollectionReference get trocasRef => firestore.collection('trocas');

  Future<List<Produto>> getProdutos() async {
    final snapshot = await produtosRef.get();
    return snapshot.docs
        .map((doc) => Produto.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Produto> getProdutoById(String id) async {
    final doc = await produtosRef.doc(id).get();
    return Produto.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> adicionarProduto(Produto produto) async {
    await produtosRef.doc(produto.id).set(produto.toJson());
  }

  Future<void> editarProduto(Produto produto) async {
    await produtosRef.doc(produto.id).update(produto.toJson());
  }

  Future<void> removerProduto(String id) async {
    await produtosRef.doc(id).delete();
  }

  Future<String> trocarProduto({
    required String produtoId,
    required String alunoId,
    required String codigoTroca,
  }) async {
    final troca = TrocaProduto(
      id: produtosRef.doc().id,
      produtoId: produtoId,
      alunoId: alunoId,
      codigoTroca: codigoTroca,
      data: DateTime.now(),
      status: 'pendente',
    );
    await trocasRef.doc(troca.id).set(troca.toJson());
    return codigoTroca;
  }

  Future<List<TrocaProduto>> getTrocasByAluno(String alunoId) async {
    final snapshot = await trocasRef.where('alunoId', isEqualTo: alunoId).get();
    return snapshot.docs
        .map((doc) => TrocaProduto.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String> trocarProdutoTransacional({
    required String produtoId,
    required String alunoId,
    required int precoProduto,
    required String codigoTroca,
  }) async {
    return await firestore.runTransaction((transaction) async {
      final produtoDoc = produtosRef.doc(produtoId);
      final alunoDoc = firestore.collection('users').doc(alunoId);
      final trocaDoc = trocasRef.doc();

      // Buscar produto
      final produtoSnapshot = await transaction.get(produtoDoc);
      if (!produtoSnapshot.exists) {
        throw Exception('Produto não encontrado');
      }
      final produtoData = produtoSnapshot.data() as Map<String, dynamic>;
      final quantidadeAtual = produtoData['quantidade'] ?? 0;
      if (quantidadeAtual <= 0) {
        throw Exception('Produto esgotado');
      }

      // Buscar aluno
      final alunoSnapshot = await transaction.get(alunoDoc);
      if (!alunoSnapshot.exists) {
        throw Exception('Aluno não encontrado');
      }
      final alunoData = alunoSnapshot.data() as Map<String, dynamic>;
      final saldoAtual = alunoData['staircoins'] ?? 0;
      if (saldoAtual < precoProduto) {
        throw Exception('Moedas insuficientes');
      }

      // Atualizar produto
      transaction.update(produtoDoc, {'quantidade': quantidadeAtual - 1});
      // Atualizar saldo do aluno
      transaction.update(alunoDoc, {'staircoins': saldoAtual - precoProduto});
      // Registrar troca
      final troca = TrocaProduto(
        id: trocaDoc.id,
        produtoId: produtoId,
        alunoId: alunoId,
        codigoTroca: codigoTroca,
        data: DateTime.now(),
        status: 'pendente',
      );
      transaction.set(trocaDoc, troca.toJson());
      return codigoTroca;
    });
  }

  Future<List<Produto>> getProdutosPorTurmas(
      List<String> turmasIds, List<String> professoresIds) async {
    // Se a lista de IDs estiver vazia, retorne lista vazia
    if (turmasIds.isEmpty) {
      print('Lista de turmasIds vazia, retornando lista vazia');
      return [];
    }

    List<Produto> produtosPorTurma = [];
    List<Produto> produtosPorProfessor = [];

    try {
      print('==== INÍCIO DO LOG DE FILTRAGEM DE PRODUTOS ====');
      print('Filtrando por turmas: $turmasIds');
      print('Filtrando por professores: $professoresIds');

      // PRIMEIRA CONSULTA: Produtos por turma
      try {
        if (turmasIds.isNotEmpty) {
          for (int i = 0; i < turmasIds.length; i += 10) {
            // Firestore limita a 10 valores em whereIn
            final batchTurmas = turmasIds.sublist(
                i, i + 10 > turmasIds.length ? turmasIds.length : i + 10);

            print('Consultando batch de turmas ${i ~/ 10 + 1}: $batchTurmas');

            final snapshot =
                await produtosRef.where('turmaId', whereIn: batchTurmas).get();

            print(
                'Encontrados ${snapshot.docs.length} produtos para o batch de turmas ${i ~/ 10 + 1}');

            // Adicionar produtos encontrados por turma
            for (var doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;

              final quantidade = data['quantidade'] ?? 0;
              if (quantidade > 0) {
                produtosPorTurma.add(Produto.fromJson(data));
                print('Produto adicionado por turma: ${data['nome']}');
              }
            }
          }
        }
      } catch (e) {
        print('Erro na consulta por turmas: $e');
      }

      // SEGUNDA CONSULTA: Produtos por professor
      try {
        if (professoresIds.isNotEmpty) {
          for (int i = 0; i < professoresIds.length; i += 10) {
            // Firestore limita a 10 valores em whereIn
            final batchProfs = professoresIds.sublist(
                i,
                i + 10 > professoresIds.length
                    ? professoresIds.length
                    : i + 10);

            print(
                'Consultando batch de professores ${i ~/ 10 + 1}: $batchProfs');

            final snapshot = await produtosRef
                .where('professorId', whereIn: batchProfs)
                .get();

            print(
                'Encontrados ${snapshot.docs.length} produtos para o batch de professores ${i ~/ 10 + 1}');

            // Adicionar produtos encontrados por professor
            for (var doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;

              final quantidade = data['quantidade'] ?? 0;
              if (quantidade > 0) {
                // Verificar se o produto já foi adicionado (para evitar duplicatas)
                if (!produtosPorTurma.any((p) => p.id == doc.id)) {
                  produtosPorProfessor.add(Produto.fromJson(data));
                  print('Produto adicionado por professor: ${data['nome']}');
                } else {
                  print('Produto ignorado (duplicata): ${data['nome']}');
                }
              }
            }
          }
        }
      } catch (e) {
        print('Erro na consulta por professores: $e');
      }

      // Combinar os resultados
      final todosProdutos = [...produtosPorTurma, ...produtosPorProfessor];

      print('Total de produtos por turma: ${produtosPorTurma.length}');
      print('Total de produtos por professor: ${produtosPorProfessor.length}');
      print('Total de produtos únicos: ${todosProdutos.length}');
      print('==== FIM DO LOG DE FILTRAGEM DE PRODUTOS ====');

      return todosProdutos;
    } catch (e) {
      print('Erro geral na busca de produtos: $e');
      return [];
    }
  }
}
