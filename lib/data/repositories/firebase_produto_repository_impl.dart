import 'package:dartz/dartz.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/models/troca_produto.dart';
import 'package:staircoins/domain/repositories/produto_repository.dart';
import 'package:staircoins/data/datasources/firebase_produto_datasource.dart';

class FirebaseProdutoRepositoryImpl implements ProdutoRepository {
  final FirebaseProdutoDatasource datasource;
  FirebaseProdutoRepositoryImpl(this.datasource);

  @override
  Future<Either<Exception, List<Produto>>> getProdutos() async {
    try {
      final produtos = await datasource.getProdutos();
      return Right(produtos);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Produto>> getProdutoById(String id) async {
    try {
      final produto = await datasource.getProdutoById(id);
      return Right(produto);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> adicionarProduto(Produto produto) async {
    try {
      await datasource.adicionarProduto(produto);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> editarProduto(Produto produto) async {
    try {
      await datasource.editarProduto(produto);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> removerProduto(String id) async {
    try {
      await datasource.removerProduto(id);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, String>> trocarProduto({
    required String produtoId,
    required String alunoId,
  }) async {
    try {
      // Buscar produto para pegar o preço
      final produto = await datasource.getProdutoById(produtoId);
      final codigoTroca = _gerarCodigoTroca();
      final codigo = await datasource.trocarProdutoTransacional(
        produtoId: produtoId,
        alunoId: alunoId,
        precoProduto: produto.preco,
        codigoTroca: codigoTroca,
      );
      return Right(codigo);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<TrocaProduto>>> getTrocasByAluno(
      String alunoId) async {
    try {
      final trocas = await datasource.getTrocasByAluno(alunoId);
      return Right(trocas);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  String _gerarCodigoTroca() {
    const prefixo = "STC";
    const caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var codigo = "$prefixo-";
    for (var i = 0; i < 6; i++) {
      codigo +=
          caracteres[DateTime.now().millisecondsSinceEpoch % caracteres.length];
    }
    return codigo;
  }
}
