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
}
