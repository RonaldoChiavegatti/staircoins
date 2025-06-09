import 'package:dartz/dartz.dart';
import 'package:staircoins/models/produto.dart';
import 'package:staircoins/models/troca_produto.dart';

abstract class ProdutoRepository {
  Future<Either<Exception, List<Produto>>> getProdutos();
  Future<Either<Exception, Produto>> getProdutoById(String id);
  Future<Either<Exception, void>> adicionarProduto(Produto produto);
  Future<Either<Exception, void>> editarProduto(Produto produto);
  Future<Either<Exception, void>> removerProduto(String id);

  // Troca de produtos
  Future<Either<Exception, String>> trocarProduto({
    required String produtoId,
    required String alunoId,
  });
  Future<Either<Exception, List<TrocaProduto>>> getTrocasByAluno(
      String alunoId);
}
