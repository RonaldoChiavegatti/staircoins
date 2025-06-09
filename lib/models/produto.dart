class Produto {
  final String id;
  final String nome;
  final String descricao;
  final int preco;
  final int quantidade;
  final String? imagem;
  final String? pesoTamanho;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidade,
    this.imagem,
    this.pesoTamanho,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      preco: json['preco'] ?? 0,
      quantidade: json['quantidade'] ?? 0,
      imagem: json['imagem'] is String ? json['imagem'] : null,
      pesoTamanho: json['pesoTamanho'] is String ? json['pesoTamanho'] : null,
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
      'pesoTamanho': pesoTamanho,
    };
  }

  Produto copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? preco,
    int? quantidade,
    String? imagem,
    String? pesoTamanho,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
      imagem: imagem ?? this.imagem,
      pesoTamanho: pesoTamanho ?? this.pesoTamanho,
    );
  }
}
