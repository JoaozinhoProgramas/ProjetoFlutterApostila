import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config_dart.dart';
import '../../models/cliente.dart';
import '../../models/produto.dart';
import '../../models/servico.dart';
import '../../models/venda.dart';

class ApiException implements Exception {
  final String mensagem;

  const ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _headers = {'Content-Type': 'application/json; charset=UTF-8'};

  // Interpreta a resposta e transforma erros HTTP em mensagens úteis para a tela.
  dynamic _processar(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        body = null; // Resposta que não é JSON (ex.: página de erro do servidor).
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    final mensagem = body is Map ? body['mensagem'] : null;
    throw ApiException(
      mensagem?.toString() ?? 'Erro HTTP ${response.statusCode}.',
    );
  }

  // ---------------------------------------------------------------- Clientes

  Future<List<Cliente>> listarClientes() async {
    final response =
        await _client.get(Uri.parse('${ApiConfig.baseUrl}/clientes'));
    return (_processar(response) as List)
        .map((e) => Cliente.fromJson(e))
        .toList();
  }

  Future<Cliente> salvarCliente(Cliente cliente) async {
    final uri = cliente.id == null
        ? '${ApiConfig.baseUrl}/clientes'
        : '${ApiConfig.baseUrl}/clientes/${cliente.id}';
    final response = cliente.id == null
        ? await _client.post(Uri.parse(uri),
            headers: _headers, body: jsonEncode(cliente.toJson()))
        : await _client.put(Uri.parse(uri),
            headers: _headers, body: jsonEncode(cliente.toJson()));
    return Cliente.fromJson(_processar(response));
  }

  Future<void> excluirCliente(int id) async {
    _processar(
        await _client.delete(Uri.parse('${ApiConfig.baseUrl}/clientes/$id')));
  }

  // ---------------------------------------------------------------- Produtos

  Future<List<Produto>> listarProdutos() async {
    final response =
        await _client.get(Uri.parse('${ApiConfig.baseUrl}/produtos'));
    return (_processar(response) as List)
        .map((e) => Produto.fromJson(e))
        .toList();
  }

  Future<Produto> salvarProduto(Produto produto) async {
    final uri = produto.id == null
        ? '${ApiConfig.baseUrl}/produtos'
        : '${ApiConfig.baseUrl}/produtos/${produto.id}';
    final response = produto.id == null
        ? await _client.post(Uri.parse(uri),
            headers: _headers, body: jsonEncode(produto.toJson()))
        : await _client.put(Uri.parse(uri),
            headers: _headers, body: jsonEncode(produto.toJson()));
    return Produto.fromJson(_processar(response));
  }

  Future<void> excluirProduto(int id) async {
    _processar(
        await _client.delete(Uri.parse('${ApiConfig.baseUrl}/produtos/$id')));
  }

  // ---------------------------------------------------------------- Serviços

  Future<List<Servico>> listarServicos() async {
    final response =
        await _client.get(Uri.parse('${ApiConfig.baseUrl}/servicos'));
    return (_processar(response) as List)
        .map((e) => Servico.fromJson(e))
        .toList();
  }

  Future<Servico> salvarServico(Servico servico) async {
    final uri = servico.id == null
        ? '${ApiConfig.baseUrl}/servicos'
        : '${ApiConfig.baseUrl}/servicos/${servico.id}';
    final response = servico.id == null
        ? await _client.post(Uri.parse(uri),
            headers: _headers, body: jsonEncode(servico.toJson()))
        : await _client.put(Uri.parse(uri),
            headers: _headers, body: jsonEncode(servico.toJson()));
    return Servico.fromJson(_processar(response));
  }

  Future<void> excluirServico(int id) async {
    _processar(
        await _client.delete(Uri.parse('${ApiConfig.baseUrl}/servicos/$id')));
  }

  // ------------------------------------------------------------------ Vendas

  Future<List<Venda>> listarVendas() async {
    final response =
        await _client.get(Uri.parse('${ApiConfig.baseUrl}/vendas'));
    return (_processar(response) as List)
        .map((e) => Venda.fromJson(e))
        .toList();
  }

  Future<Venda> criarVenda({
    required int clienteId,
    required List<Map<String, dynamic>> itens,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/vendas'),
      headers: _headers,
      body: jsonEncode({'clienteId': clienteId, 'itens': itens}),
    );
    return Venda.fromJson(_processar(response));
  }

  Future<Venda> cancelarVenda(int id) async {
    final response = await _client
        .patch(Uri.parse('${ApiConfig.baseUrl}/vendas/$id/cancelamento'));
    return Venda.fromJson(_processar(response));
  }
}