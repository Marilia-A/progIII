import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/atividade.dart';
import '../routes.dart';
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
  String? erro;

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

  Future<void> editar(Atividade atividade) async {
    final salvou = await Navigator.pushNamed(
      context,
      AppRoutes.formulario,
      arguments: atividade,
    );
    if (salvou == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> excluir(Atividade atividade) async {
    final certeza = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir ${atividade.titulo}?'),
        content: const Text(
          'Tem certeza? A atividade sai da sua lista, e não dá para desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (certeza != true || !mounted) {
      return;
    }
    try {
      await context.read<AtividadeService>().excluir(atividade.id);
    } on ErroDeAtividades catch (e) {
      setState(() {
        erro = '$e';
      });
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => editar(atividade),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => excluir(atividade),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                  ),
                ],
              ),
              if (erro != null) ...[
                const SizedBox(height: 16),
                Text(
                  erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}