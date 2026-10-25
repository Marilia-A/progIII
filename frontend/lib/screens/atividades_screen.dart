import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/atividade.dart';
import '../routes.dart';
import '../services/atividade_service.dart';
import '../widgets/app_drawer.dart';

class AtividadesScreen extends StatefulWidget {
  const AtividadesScreen({super.key});

  @override
  State<AtividadesScreen> createState() => _AtividadesScreenState();
}

class _AtividadesScreenState extends State<AtividadesScreen> {
  late Future<List<Atividade>> atividades;

  @override
  void initState() {
    super.initState();
    atividades = context.read<AtividadeService>().listar();
  }

  void pedirDeNovo() {
    setState(() {
      atividades = context.read<AtividadeService>().listar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Atividade>>(
        future: atividades,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 56),
                  const SizedBox(height: 16),
                  const Text('Não consegui carregar as atividades'),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: pedirDeNovo,
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            );
          }
          final lista = snapshot.data!;
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhuma atividade ainda.'));
          }
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final atividade = lista[i];
              return ListTile(
                leading: const Icon(Icons.checklist),
                title: Text(atividade.titulo),
                subtitle: Text(
                  '${atividade.nomeDaCategoria} · ${atividade.dataFormatada}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final mudou = await Navigator.pushNamed(
                    context,
                    AppRoutes.atividade,
                    arguments: atividade.id,
                  );
                  if (mudou == true) {
                    pedirDeNovo();
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova atividade',
        onPressed: () async {
          final salvou = await Navigator.pushNamed(context, AppRoutes.formulario);
          if (salvou == true) {
            pedirDeNovo();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}