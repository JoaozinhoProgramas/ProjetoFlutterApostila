import 'package:flutter/material.dart';
import 'clientes_page.dart';

//import 'produtos_page.dart';
//import 'servicos_page.dart';
//import 'vendas_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indice = 0;
  final _paginas = const [
    ClientesPage(),
    //ProdutosPage(),
    //ServicosPage(),
    //VendasPage()
  ];
  final _titulos = const ['Clientes', 'Produtos', 'Serviços', 'Vendas'];
  final _destinos = const [
    NavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: 'Clientes'),
    NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Produtos'),
    NavigationDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: 'Serviços'),
    NavigationDestination(
        icon: Icon(Icons.point_of_sale_outlined),
        selectedIcon: Icon(Icons.point_of_sale),
        label: 'Vendas'),
  ];
  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final desktop = largura >= 800;
    return Scaffold(
      appBar: AppBar(title: Text('Gestão Comercial • ${_titulos[_indice]}')),
      body: Row(children: [
        if (desktop)
          NavigationRail(
            selectedIndex: _indice,
            onDestinationSelected: (valor) => setState(() => _indice = valor),
            labelType: NavigationRailLabelType.all,
            destinations: _destinos
                .map((d) => NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label)))
                .toList(),
          ),
        Expanded(child: IndexedStack(index: _indice, children: _paginas)),
      ]),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: (valor) => setState(() => _indice = valor),
              destinations: _destinos),
    );
  }
}
