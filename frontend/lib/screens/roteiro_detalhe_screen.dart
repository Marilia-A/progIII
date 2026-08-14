import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/models.dart';
import '../widgets/estados.dart';
import 'roteiro_form_screen.dart';

/// TELA 5 — Detalhe de um roteiro, com editar e excluir.
/// Excluir pede confirmação. Concluir dá a medalha.
class RoteiroDetalheScreen extends StatefulWidget {
  const RoteiroDetalheScreen({super.key, required this.id});
  final String id;

  @override
  State<RoteiroDetalheScreen> createState() => _RoteiroDetalheScreenState();
}

class _RoteiroDetalheScreenState extends State<RoteiroDetalheScreen> {
  bool _processando = false;

  Roteiro? get _roteiro => Repositorio.instance.porId(widget.id);

  Future<void> _editar() async {
    final r = _roteiro;
    if (r == null) return;
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RoteiroFormScreen(roteiro: r)),
    );
    if (salvou == true && mounted) setState(() {});
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir roteiro?"),
        content: const Text(
            "Esta ação não pode ser desfeita. O conteúdo e os passos serão removidos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _processando = true);
    try {
      await Repositorio.instance.excluir(widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Roteiro excluído.")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _processando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  Future<void> _concluir() async {
    setState(() => _processando = true);
    await Repositorio.instance.concluir(widget.id);
    if (!mounted) return;
    setState(() => _processando = false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.military_tech,
            size: 56, color: Theme.of(ctx).colorScheme.tertiary),
        title: const Text("Roteiro concluído!"),
        content: const Text(
            "Parabéns! Você ganhou uma medalha por finalizar este roteiro."),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Aê!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _roteiro;
    final scheme = Theme.of(context).colorScheme;

    // Estado de erro: roteiro não existe mais.
    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detalhe")),
        body: EstadoErro(
          mensagem: "Este roteiro não está mais disponível.",
          onTentarNovamente: () => Navigator.of(context).pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhe do roteiro"),
        actions: [
          IconButton(
            tooltip: "Editar",
            onPressed: _processando ? null : _editar,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: "Excluir",
            onPressed: _processando ? null : _confirmarExclusao,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            if (r.concluido)
              Card(
                color: scheme.tertiaryContainer,
                child: ListTile(
                  leading: Icon(Icons.military_tech,
                      color: scheme.onTertiaryContainer),
                  title: Text(
                    "Medalha conquistada",
                    style: TextStyle(color: scheme.onTertiaryContainer),
                  ),
                  subtitle: Text(
                    "Você já finalizou este roteiro.",
                    style: TextStyle(color: scheme.onTertiaryContainer),
                  ),
                ),
              ),
            if (r.concluido) const SizedBox(height: 16),

            Text("Conteúdo",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              "${r.conteudo.passoAPasso.length} passos · ${r.conteudo.imagens.length} imagens",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Passo a passo
            Text("Passo a passo",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (r.conteudo.passoAPasso.isEmpty)
              Text("Sem passos cadastrados.",
                  style: Theme.of(context).textTheme.bodyMedium)
            else
              for (int i = 0; i < r.conteudo.passoAPasso.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: scheme.primaryContainer,
                        child: Text(
                          "${i + 1}",
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(r.conteudo.passoAPasso[i].descricao),
                        ),
                      ),
                    ],
                  ),
                ),

            const SizedBox(height: 24),

            // Imagens
            Text("Imagens",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (r.conteudo.imagens.isEmpty)
              Text("Nenhuma imagem neste conteúdo.",
                  style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final img in r.conteudo.imagens)
                Card(
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(Icons.image_outlined,
                              size: 48, color: scheme.onSurfaceVariant),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(img.legenda),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: r.concluido
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _processando ? null : _concluir,
                  icon: _processando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.emoji_events_outlined),
                  label: const Text("Concluir e ganhar medalha"),
                ),
              ),
            ),
    );
  }
}
