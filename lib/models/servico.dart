class Servico {
  final int? id;
  final String nome;
  final String? descricao;
  final double preco;
  final bool ativo;
  const Servico({
    this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    this.ativo = true,
  });
  factory Servico.fromJson(Map<String, dynamic> json) => Servico(
    id: json['id'] as int?,
    nome: json['nome'] ?? '',
    descricao: json['descricao'],
    preco: (json['preco'] as num).toDouble(),
    ativo: json['ativo'] ?? true,
  );
  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
    'preco': preco,
    'ativo': ativo,
  };
}
