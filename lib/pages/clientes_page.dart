import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/api_services.dart';
import '../widget/ui_helpers.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});
  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final _api = ApiService();
  List<Cliente> _clientes = [];
  bool _carregando = true;
  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _clientes = await _api.listarClientes();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirFormulario([Cliente? cliente]) async {
    final formKey = GlobalKey<FormState>();
    final nome = TextEditingController(text: cliente?.nome);
    final documento = TextEditingController(text: cliente?.documento);
    final email = TextEditingController(text: cliente?.email);
    final telefone = TextEditingController(text: cliente?.telefone);
    final endereco = TextEditingController(text: cliente?.endereco);
    bool ativo = cliente?.ativo ?? true;
    final salvo = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title:
                      Text(cliente == null ? 'Novo cliente' : 'Editar cliente'),
                  content: SizedBox(
                      width: 520,
                      child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                TextFormField(
                                    controller: nome,
                                    decoration: const InputDecoration(
                                        labelText: 'Nome'),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Informe o nome.'
                                            : null),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: documento,
                                    decoration: const InputDecoration(
                                        labelText: 'CPF/CNPJ'),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Informe o documento.'
                                            : null),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: email,
                                    decoration: const InputDecoration(
                                        labelText: 'E-mail'),
                                    keyboardType: TextInputType.emailAddress),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: telefone,
                                    decoration: const InputDecoration(
                                        labelText: 'Telefone')),
                                const SizedBox(height: 12),
                                TextFormField(
                                    controller: endereco,
                                    decoration: const InputDecoration(
                                        labelText: 'Endereço')),
                                SwitchListTile(
                                    value: ativo,
                                    onChanged: (v) =>
                                        setDialogState(() => ativo = v),
                                    title: const Text('Cliente ativo')),
                              ])))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          try {
                            await _api.salvarCliente(Cliente(
                                id: cliente?.id,
                                nome: nome.text.trim(),
                                documento: documento.text.trim(),
                                email: email.text.trim().isEmpty
                                    ? null
                                    : email.text.trim(),
                                telefone: telefone.text.trim(),
                                endereco: endereco.text.trim(),
                                ativo: ativo));
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (e) {
                            if (context.mounted)mostrarMensagem(context, e.toString(), erro: true);
                          }
                        },
                        child: const Text('Salvar'))
                  ],
                )));
    if (salvo == true) {
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Cliente salvo com   sucesso.');
    }
  }

  Future<void> _excluir(Cliente cliente) async {
    if (!await confirmarExclusao(context, cliente.nome)) return;
    try {
      await _api.excluirCliente(cliente.id!);
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Cliente excluído.');
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _carregando
            ? const LoadingView()
            : RefreshIndicator(
                onRefresh: _carregar,
                child: _clientes.isEmpty
                    ? const EmptyView('Nenhum cliente cadastrado.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _clientes.length,
                        itemBuilder: (_, i) {
                          final c = _clientes[i];
                          return Card(
                              child: ListTile(
                            leading: CircleAvatar(
                                child: Text(c.nome.isEmpty
                                    ? '?'
                                    : c.nome[0].toUpperCase())),
                            title: Text(c.nome),
                            subtitle: Text(
                                '${c.documento} • ${c.email ?? 'sem e-mail'}'),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(c.ativo ? Icons.check_circle : Icons.block,
                                  color: c.ativo ? Colors.green : Colors.grey),
                              IconButton(
                                  onPressed: () => _abrirFormulario(c),
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () => _excluir(c),
                                  icon: const Icon(Icons.delete_outline))
                            ]),
                          ));
                        },
                      ),
              ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.add),
            label: const Text('Novo cliente')),
      );
}
