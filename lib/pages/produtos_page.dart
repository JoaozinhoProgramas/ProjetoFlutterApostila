import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/produto.dart';
import '../services/api_services.dart';
import '../widget/ui_helpers.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});
  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final _api = ApiService();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  List<Produto> _itens = [];
  bool _carregando = true;
  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _itens = await _api.listarProdutos();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _formulario([Produto? produto]) async {
    final key = GlobalKey<FormState>();
    final nome = TextEditingController(text: produto?.nome);
    final descricao = TextEditingController(text: produto?.descricao);
    final preco = TextEditingController(
        text: produto?.preco.toStringAsFixed(2).replaceAll('.', ','));
    final estoque =
        TextEditingController(text: produto?.estoque.toString() ?? '0');
    bool ativo = produto?.ativo ?? true;
    final salvo = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setLocal) => AlertDialog(
                  title:
                      Text(produto == null ? 'Novo produto' : 'Editar produto'),
                  content: SizedBox(
                      width: 500,
                      child: Form(
                          key: key,
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                TextFormField(
                                    controller: nome,
                                    decoration: const InputDecoration(
                                        labelText: 'Nome'),
                                    validator: _obrigatorio),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: descricao,
                                    decoration: const InputDecoration(
                                        labelText: 'Descrição'),
                                    maxLines: 2),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: preco,
                                    decoration: const InputDecoration(
                                        labelText: 'Preço'),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: _numeroPositivo),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: estoque,
                                    decoration: const InputDecoration(
                                        labelText: 'Estoque'),
                                    keyboardType: TextInputType.number,
                                    validator: _inteiroNaoNegativo),
                                SwitchListTile(
                                    value: ativo,
                                    onChanged: (v) => setLocal(() => ativo = v),
                                    title: const Text('Produto ativo')),
                              ])))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () async {
                          if (!key.currentState!.validate()) return;
                          try {
                            await _api.salvarProduto(Produto(
                                id: produto?.id,
                                nome: nome.text.trim(),
                                descricao: descricao.text.trim(),
                                preco: double.parse(
                                    preco.text.replaceAll(',', '.')),
                                estoque: int.parse(estoque.text),
                                ativo: ativo));
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (e) {
                            if (context.mounted) mostrarMensagem(context, e.toString(), erro: true);
                          }
                        },
                        child: const Text('Salvar'))
                  ],
                )));
    if (salvo == true) {
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Produto salvo.');
    }
  }

  String? _obrigatorio(String? v) =>
      v == null || v.trim().isEmpty ? 'Campo obrigatório.' : null;
  String? _numeroPositivo(String? v) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    return n == null || n < 0 ? 'Informe um valor válido.' : null;
  }

  String? _inteiroNaoNegativo(String? v) {
    final n = int.tryParse(v ?? '');
    return n == null || n < 0 ? 'Informe um número inteiro válido.' : null;
  }

  Future<void> _excluir(Produto p) async {
    if (!await confirmarExclusao(context, p.nome)) return;
    try {
      await _api.excluirProduto(p.id!);
      await _carregar();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _carregando
            ? const LoadingView()
            : _itens.isEmpty
                ? const EmptyView('Nenhum produto   cadastrado.')
                : RefreshIndicator(
                    onRefresh: _carregar,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _itens.length,
                        itemBuilder: (_, i) {
                          final p = _itens[i];
                          return Card(
                              child: ListTile(
                            leading: const CircleAvatar(
                                child: Icon(Icons.inventory_2)),
                            title: Text(p.nome),
                            subtitle: Text(
                                '${_moeda.format(p.preco)} • Estoque: ${p.estoque}'),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  onPressed: () => _formulario(p),
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () => _excluir(p),
                                  icon: const Icon(Icons.delete_outline))
                            ]),
                          ));
                        })),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _formulario(),
            icon: const Icon(Icons.add),
            label: const Text('Novo produto')),
      );
}
