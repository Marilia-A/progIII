import 'package:flutter/material.dart';
import '../models/atividade.dart';
import '../services/api_service.dart';
import 'formulario_screen.dart';

class DetalheScreen extends StatelessWidget {
  final Atividade atividade;

  const DetalheScreen({super.key, required this.atividade});

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir atividade?'),
        content: Text('Tem certeza que deseja excluir "${atividade.titulo}"? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;
    if (!context.mounted) return;

    try {
      await ApiService().apagar(atividade.id!);
      if (!context.mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir atividade.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da atividade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final alterou = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => FormularioScreen(atividade: atividade)),
              );
              if (alterou == true && context.mounted) Navigator.pop(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(atividade.titulo, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Chip(label: Text(atividade.categoria.valor)),
            const SizedBox(height: 16),
            if (atividade.descricao != null) ...[
              Text(atividade.descricao!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(
                  atividade.concluida ? Icons.check_circle : Icons.circle_outlined,
                  color: atividade.concluida ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(atividade.concluida ? 'Concluída' : 'Pendente'),
              ],
            ),
            if (atividade.dataPrevista != null) ...[
              const SizedBox(height: 8),
              Text(
                'Data prevista: ${atividade.dataPrevista!.day}/${atividade.dataPrevista!.month}/${atividade.dataPrevista!.year}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}