class Produto {
  final int? id;
  final String nome;
  final String? descricao;
  final double preco;
  final int estoque;
  final bool ativo;
  const Produto({
    this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.estoque,
    this.ativo = true,
  });
  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
    id: json['id'] as int?,
    nome: json['nome'] ?? '',
    descricao: json['descricao'],
    preco: (json['preco'] as num).toDouble(),
    estoque: json['estoque'] ?? 0,
    ativo: json['ativo'] ?? true,
  );
  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
    'preco': preco,
    'estoque': estoque,
    'ativo': ativo,
  };
}
