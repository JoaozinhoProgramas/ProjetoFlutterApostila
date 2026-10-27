import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/servico.dart';
import '../services/api_services.dart';
import '../widget/ui_helpers.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({super.key});
  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  final _api = ApiService();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  List<Servico> _itens = [];
  bool _carregando = true;
  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _itens = await _api.listarServicos();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _formulario([Servico? servico]) async {
    final key = GlobalKey<FormState>();
    final nome = TextEditingController(text: servico?.nome);
    final descricao = TextEditingController(text: servico?.descricao);
    final preco = TextEditingController(
        text: servico?.preco.toStringAsFixed(2).replaceAll('.', ','));
    bool ativo = servico?.ativo ?? true;
    final salvo = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setLocal) => AlertDialog(
                  title:
                      Text(servico == null ? 'Novo serviço' : 'Editar serviço'),
                  content: SizedBox(
                      width: 500,
                      child: Form(
                          key: key,
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            TextFormField(
                                controller: nome,
                                decoration:
                                    const InputDecoration(labelText: 'Nome'),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Informe o nome.'
                                    : null),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: descricao,
                                decoration: const InputDecoration(
                                    labelText: 'Descrição'),
                                maxLines: 2),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: preco,
                                decoration:
                                    const InputDecoration(labelText: 'Preço'),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) {
                                  final n = double.tryParse(
                                      (v ?? '').replaceAll(',', '.'));
                                  return n == null || n < 0
                                      ? 'Informe um preço   válido.'
                                      : null;
                                }),
                            SwitchListTile(
                                value: ativo,
                                onChanged: (v) => setLocal(() => ativo = v),
                                title: const Text('Serviço ativo')),
                          ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () async {
                          if (!key.currentState!.validate()) return;
                          try {
                            await _api.salvarServico(Servico(
                                id: servico?.id,
                                nome: nome.text.trim(),
                                descricao: descricao.text.trim(),
                                preco: double.parse(
                                    preco.text.replaceAll(',', '.')),
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
      if (mounted) mostrarMensagem(context, 'Serviço salvo.');
    }
  }

  Future<void> _excluir(Servico s) async {
    if (!await confirmarExclusao(context, s.nome)) return;
    try {
      await _api.excluirServico(s.id!);
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
                ? const EmptyView('Nenhum serviço   cadastrado.')
                : RefreshIndicator(
                    onRefresh: _carregar,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _itens.length,
                        itemBuilder: (_, i) {
                          final s = _itens[i];
                          return Card(
                              child: ListTile(
                            leading:
                                const CircleAvatar(child: Icon(Icons.build)),
                            title: Text(s.nome),
                            subtitle: Text(
                                '${_moeda.format(s.preco)} • ${s.ativo ? 'Ativo' : 'Inativo'}'),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  onPressed: () => _formulario(s),
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () => _excluir(s),
                                  icon: const Icon(Icons.delete_outline))
                            ]),
                          ));
                        })),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _formulario(),
            icon: const Icon(Icons.add),
            label: const Text('Novo serviço')),
      );
}
