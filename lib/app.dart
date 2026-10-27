import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class GestaoComercialApp extends StatelessWidget {
  const GestaoComercialApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão Comercial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5AA8)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.all(8)),
      ),
      home: const HomePage(),
    );
  }
}
