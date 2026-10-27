class ItemVenda {
  final int? id;
  final String tipo;
  final int referenciaId;
  final String descricao;
  final int quantidade;
  final double valorUnitario;
  final double subtotal;
  const ItemVenda({
    this.id,
    required this.tipo,
    required this.referenciaId,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
    required this.subtotal,
  });
  factory ItemVenda.fromJson(Map<String, dynamic> json) => ItemVenda(
    id: json['id'],
    tipo: json['tipo'] ?? '',
    referenciaId: json['referenciaId'] ?? 0,
    descricao: json['descricao'] ?? '',
    quantidade: json['quantidade'] ?? 0,
    valorUnitario: (json['valorUnitario'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
  );
}

class Venda {
  final int id;
  final ClienteResumo cliente;
  final DateTime dataHora;
  final String status;
  final double valorTotal;
  final List<ItemVenda> itens;
  const Venda({
    required this.id,
    required this.cliente,
    required this.dataHora,
    required this.status,
    required this.valorTotal,
    required this.itens,
  });
  factory Venda.fromJson(Map<String, dynamic> json) => Venda(
    id: json['id'],
    cliente: ClienteResumo.fromJson(json['cliente']),
    dataHora: DateTime.parse(json['dataHora']),
    status: json['status'],
    valorTotal: (json['valorTotal'] as num).toDouble(),
    itens: (json['itens'] as List).map((e) => ItemVenda.fromJson(e)).toList(),
  );
}


class ClienteResumo {
  final int id;
  final String nome;
  const ClienteResumo({required this.id, required this.nome});
  factory ClienteResumo.fromJson(Map<String, dynamic> json) =>
      ClienteResumo(id: json['id'], nome: json['nome']);
}
