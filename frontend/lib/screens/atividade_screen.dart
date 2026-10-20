import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/atividade.dart';
import '../services/atividade_service.dart';
import 'atividades_screen.dart';

class AtividadeScreen extends StatefulWidget {
  const AtividadeScreen({super.key, this.id});

  final int? id;

  @override
  State<AtividadeScreen> createState() => _AtividadeScreenState();
}

class _AtividadeScreenState extends State<AtividadeScreen> {
  late Future<Atividade> pedido;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      pedido = context.read<AtividadeService>().buscar(widget.id!);
    }
  }

  void tentarDeNovo() {
    setState(() {
      pedido = context.read<AtividadeService>().buscar(widget.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == null) {
      return const AtividadesScreen();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Atividade')),
      body: FutureBuilder<Atividade>(
        future: pedido,
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
                  const Text('Não consegui carregar a atividade'),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: tentarDeNovo,
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            );
          }
          final atividade = snapshot.data!;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('Título'),
                subtitle: Text(atividade.titulo),
              ),
              ListTile(
                leading: const Icon(Icons.notes),
                title: const Text('Descrição'),
                subtitle: Text(atividade.descricao ?? 'Sem descrição'),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categoria'),
                subtitle: Text(atividade.nomeDaCategoria),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Data prevista'),
                subtitle: Text(atividade.dataFormatada),
              ),
              ListTile(
                leading: Icon(
                  atividade.concluida ? Icons.check_circle : Icons.schedule,
                ),
                title: const Text('Situação'),
                subtitle: Text(atividade.concluida ? 'Concluída' : 'Pendente'),
              ),
            ],
          );
        },
      ),
    );
  }
}