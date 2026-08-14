import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/models.dart';
import '../widgets/estados.dart';

/// TELA 4 — Formulário de criar/editar roteiro, com validações visíveis.
///
/// Um roteiro é composto pelo seu CONTEÚDO: passo a passo e imagens.
class RoteiroFormScreen extends StatefulWidget {
  const RoteiroFormScreen({super.key, this.roteiro});

  /// Se nulo, é criação. Caso contrário, é edição.
  final Roteiro? roteiro;

  @override
  State<RoteiroFormScreen> createState() => _RoteiroFormScreenState();
}

class _RoteiroFormScreenState extends State<RoteiroFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Cópias editáveis
  late List<TextEditingController> _passos;
  late List<TextEditingController> _imagens;

  bool _salvando = false;
  String? _erro;
  bool _tentouSalvar = false;

  bool get _edicao => widget.roteiro != null;

  @override
  void initState() {
    super.initState();
    final conteudo = widget.roteiro?.conteudo;
    _passos = (conteudo?.passoAPasso.isNotEmpty ?? false)
        ? conteudo!.passoAPasso
            .map((p) => TextEditingController(text: p.descricao))
            .toList()
        : [TextEditingController()];
    _imagens = (conteudo?.imagens ?? [])
        .map((i) => TextEditingController(text: i.legenda))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _passos) {
      c.dispose();
    }
    for (final c in _imagens) {
      c.dispose();
    }
    super.dispose();
  }

  void _adicionarPasso() =>
      setState(() => _passos.add(TextEditingController()));

  void _removerPasso(int i) {
    if (_passos.length == 1) return; // sempre ao menos um campo
    setState(() {
      _passos[i].dispose();
      _passos.removeAt(i);
    });
  }

  void _adicionarImagem() =>
      setState(() => _imagens.add(TextEditingController()));

  void _removerImagem(int i) {
    setState(() {
      _imagens[i].dispose();
      _imagens.removeAt(i);
    });
  }

  Future<void> _salvar() async {
    setState(() {
      _tentouSalvar = true;
      _erro = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final conteudo = Conteudo(
      passoAPasso: _passos
          .map((c) => Passo(descricao: c.text.trim()))
          .where((p) => p.descricao.isNotEmpty)
          .toList(),
      imagens: _imagens
          .map((c) => Imagem(legenda: c.text.trim()))
          .where((i) => i.legenda.isNotEmpty)
          .toList(),
    );

    setState(() => _salvando = true);
    try {
      if (_edicao) {
        await Repositorio.instance.editar(widget.roteiro!.id, conteudo);
      } else {
        await Repositorio.instance.criar(conteudo);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_edicao
              ? "Roteiro atualizado com sucesso!"
              : "Roteiro criado com sucesso!"),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final passosPreenchidos =
        _passos.where((c) => c.text.trim().isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_edicao ? "Editar roteiro" : "Criar roteiro"),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _tentouSalvar
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (_erro != null) ...[
                BannerErro(mensagem: _erro!),
                const SizedBox(height: 16),
              ],

              // Regras / validações visíveis
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Regras do conteúdo",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      _Regra(texto: "Pelo menos 1 passo no passo a passo"),
                      _Regra(texto: "Cada passo com ao menos 5 caracteres"),
                      _Regra(texto: "Imagens são opcionais (informe a legenda)"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Passo a passo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Passo a passo",
                      style: Theme.of(context).textTheme.titleMedium),
                  Text("$passosPreenchidos preenchidos",
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _passos.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _passos[i],
                    enabled: !_salvando,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Passo ${i + 1}",
                      prefixIcon: const Icon(Icons.drag_indicator),
                      suffixIcon: _passos.length > 1
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed:
                                  _salvando ? null : () => _removerPasso(i),
                            )
                          : null,
                    ),
                    validator: (v) {
                      // O primeiro passo é obrigatório; demais, se preenchidos,
                      // precisam ter tamanho mínimo.
                      final texto = v?.trim() ?? "";
                      if (i == 0 && texto.isEmpty) {
                        return "Informe ao menos o primeiro passo";
                      }
                      if (texto.isNotEmpty && texto.length < 5) {
                        return "Descreva o passo com mais detalhes (mín. 5 caracteres)";
                      }
                      return null;
                    },
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _salvando ? null : _adicionarPasso,
                icon: const Icon(Icons.add),
                label: const Text("Adicionar passo"),
              ),

              const SizedBox(height: 32),

              // Imagens
              Text("Imagens",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_imagens.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Nenhuma imagem adicionada.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              for (int i = 0; i < _imagens.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _imagens[i],
                    enabled: !_salvando,
                    decoration: InputDecoration(
                      labelText: "Legenda da imagem ${i + 1}",
                      prefixIcon: const Icon(Icons.image_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed:
                            _salvando ? null : () => _removerImagem(i),
                      ),
                    ),
                    validator: (v) {
                      if ((v?.trim().isEmpty ?? true)) {
                        return "Informe a legenda ou remova a imagem";
                      }
                      return null;
                    },
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _salvando ? null : _adicionarImagem,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text("Adicionar imagem"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(_edicao ? "Salvar alterações" : "Criar roteiro"),
          ),
        ),
      ),
    );
  }
}

class _Regra extends StatelessWidget {
  const _Regra({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
