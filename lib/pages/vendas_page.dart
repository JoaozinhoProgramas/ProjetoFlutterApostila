import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cliente.dart';
import '../models/produto.dart';
import '../models/servico.dart';
import '../models/venda.dart';
import '../services/api_services.dart';
import '../widget/ui_helpers.dart';

class VendasPage extends StatefulWidget {
  const VendasPage({super.key});
  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  final _api = ApiService();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _data = DateFormat('dd/MM/yyyy HH:mm');
  List<Venda> _vendas = [];
  bool _carregando = true;
  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _vendas = await _api.listarVendas();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _novaVenda() async {
    try {
      final resultados = await Future.wait([
        _api.listarClientes(),
        _api.listarProdutos(),
        _api.listarServicos()
      ]);
      final clientes = resultados[0] as List<Cliente>;
      final produtos = resultados[1] as List<Produto>;
      final servicos = resultados[2] as List<Servico>;
      if (!mounted) return;
      if (clientes.isEmpty || (produtos.isEmpty && servicos.isEmpty)) {
        mostrarMensagem(
            context, 'Cadastre um cliente e pelo menos um produto ou serviço.',
            erro: true);
        return;
      }
      int? clienteId = clientes.first.id;
      String tipo = produtos.isNotEmpty ? 'PRODUTO' : 'SERVICO';
      int? referenciaId =
          produtos.isNotEmpty ? produtos.first.id : servicos.first.id;
      final quantidade = TextEditingController(text: '1');
      final itens = <Map<String, dynamic>>[];
      final criada = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(builder: (context, setLocal) {
                final List<dynamic> opcoes =
                    tipo == 'PRODUTO' ? produtos : servicos;
                return AlertDialog(
                  title: const Text('Nova venda'),
                  content: SizedBox(
                      width: 600,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        DropdownButtonFormField<int>(
                            initialValue: clienteId,
                            decoration:
                                const InputDecoration(labelText: 'Cliente'),
                            items: clientes
                                .where((c) => c.ativo)
                                .map((c) => DropdownMenuItem(
                                    value: c.id, child: Text(c.nome)))
                                .toList(),
                            onChanged: (v) => setLocal(() => clienteId = v)),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                  value: 'PRODUTO',
                                  label: Text('Produto'),
                                  icon: Icon(Icons.inventory_2)),
                              ButtonSegment(
                                  value: 'SERVICO',
                                  label: Text('Serviço'),
                                  icon: Icon(Icons.build))
                            ],
                            selected: {
                              tipo
                            },
                            onSelectionChanged: (v) => setLocal(() {
                                  tipo = v.first;
                                  referenciaId = tipo == 'PRODUTO'
                                      ? produtos.firstOrNull?.id
                                      : servicos.firstOrNull?.id;
                                })),
                        const SizedBox(height: 16),
                        if (opcoes.isNotEmpty)
                          DropdownButtonFormField<int>(
                              key: ValueKey(tipo),
                              initialValue: referenciaId,
                              decoration: InputDecoration(
                                  labelText: tipo == 'PRODUTO'
                                      ? 'Produto'
                                      : 'Serviço'),
                              items: opcoes
                                  .map((item) => DropdownMenuItem<int>(
                                      value: item.id, child: Text(item.nome)))
                                  .toList(),
                              onChanged: (v) =>
                                  setLocal(() => referenciaId = v))
                        else
                          const Text('Nenhum item deste tipo cadastrado.'),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: quantidade,
                            decoration:
                                const InputDecoration(labelText: 'Quantidade'),
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                            onPressed: referenciaId == null
                                ? null
                                : () {
                                    final q = int.tryParse(quantidade.text);
                                    if (q == null || q < 1) return;
                                    setLocal(() => itens.add({
                                          'tipo': tipo,
                                          'referenciaId': referenciaId,
                                          'quantidade': q
                                        }));
                                  },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Adicionar item')),
                        const Divider(height: 28),
                        ...itens.asMap().entries.map((e) => ListTile(
                            dense: true,
                            title: Text(
                                '${e.value['tipo']} #${e.value['referenciaId']}'),
                            subtitle:
                                Text('Quantidade:   ${e.value['quantidade']}'),
                            trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setLocal(() => itens.removeAt(e.key))))),
                      ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: itens.isEmpty
                            ? null
                            : () async {
                                try {
                                  await _api.criarVenda(
                                      clienteId: clienteId!, itens: itens);
                                  if (context.mounted) Navigator.pop(context, true);
                                } catch (e) {
                                  if (context.mounted) mostrarMensagem(context, e.toString(), erro: true);
                                }
                              },
                        child: const Text('Concluir venda'))
                  ],
                );
              }));
      if (criada == true) {
        await _carregar();
        if (mounted) mostrarMensagem(context, 'Venda registrada   com sucesso.');
      }
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  Future<void> _cancelar(Venda venda) async {
    try {
      await _api.cancelarVenda(venda.id);
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Venda cancelada e estoque devolvido.');
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _carregando
            ? const LoadingView()
            : _vendas.isEmpty
                ? const EmptyView('Nenhuma venda   registrada.')
                : RefreshIndicator(
                    onRefresh: _carregar,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _vendas.length,
                        itemBuilder: (_, i) {
                          final v = _vendas[i];
                          final cancelada = v.status == 'CANCELADA';
                          return Card(
                              child: ExpansionTile(
                            leading: CircleAvatar(child: Text('#${v.id}')),
                            title: Text(v.cliente.nome),
                            subtitle: Text(
                                '${_data.format(v.dataHora.toLocal())} • ${_moeda.format(v.valorTotal)}'),
                            trailing: Chip(
                                label: Text(v.status),
                                backgroundColor: cancelada
                                    ? Colors.red.shade100
                                    : Colors.green.shade100),
                            children: [
                              ...v.itens.map((item) => ListTile(
                                  dense: true,
                                  title: Text(item.descricao),
                                  subtitle: Text(
                                      '${item.quantidade} × ${_moeda.format(item.valorUnitario)}'),
                                  trailing:
                                      Text(_moeda.format(item.subtotal)))),
                              if (!cancelada)
                                Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: OutlinedButton.icon(
                                            onPressed: () => _cancelar(v),
                                            icon: const Icon(
                                                Icons.cancel_outlined),
                                            label:
                                                const Text('Cancelar venda'))))
                            ],
                          ));
                        })),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _novaVenda,
            icon: const Icon(Icons.add),
            label: const Text('Nova venda')),
      );
}
