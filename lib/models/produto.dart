class Produto {
  final String id;
  final String nome;
  final String descricao;
  final int preco;
  final int quantidade;
  final String? imagem;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidade,
    this.imagem,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: json['preco'],
      quantidade: json['quantidade'],
      imagem: json['imagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'quantidade': quantidade,
      'imagem': imagem,
    };
  }

  Produto copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? preco,
    int? quantidade,
    String? imagem,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
      imagem: imagem ?? this.imagem,
    );
  }
}
