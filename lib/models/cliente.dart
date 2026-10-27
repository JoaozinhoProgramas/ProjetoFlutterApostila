class Cliente {
  final int? id;
  final String nome;
  final String documento;
  final String? email;
  final String? telefone;
  final String? endereco;
  final bool ativo;
  const Cliente({
    this.id,
    required this.nome,
    required this.documento,
    this.email,
    this.telefone,
    this.endereco,
    this.ativo = true,
  });
  // Converte o JSON recebido da API em um objeto Dart.
  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'] as int?,
    nome: json['nome'] ?? '',
    documento: json['documento'] ?? '',
    email: json['email'],
    telefone: json['telefone'],
    endereco: json['endereco'],
    ativo: json['ativo'] ?? true,
  );
  // Converte o objeto em JSON para POST e PUT.
  Map<String, dynamic> toJson() => {
    'nome': nome,
    'documento': documento,
    'email': email,
    'telefone': telefone,
    'endereco': endereco,
    'ativo': ativo,
  };
}
