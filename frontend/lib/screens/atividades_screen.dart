import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AtividadesScreen extends StatelessWidget {
  const AtividadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades')),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 56),
            SizedBox(height: 16),
            Text('A lista de atividades chega adiante.'),
          ],
        ),
      ),
    );
  }
}