import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/models.dart';
import '../widgets/estados.dart';
import 'login_screen.dart';
import 'roteiro_detalhe_screen.dart';
import 'roteiro_form_screen.dart';

/// TELA 3 — Listagem de roteiro
/// Busca por conteúdo, botão de criar em destaque e estado de lista vazia.
class ListagemScreen extends StatefulWidget {
  const ListagemScreen({super.key});

  @override
  State<ListagemScreen> createState() => _ListagemScreenState();
}

enum _Status { carregando, sucesso, erro }

class _ListagemScreenState extends State<ListagemScreen> {
  final _buscaCtrl = TextEditingController();
  _Status _status = _Status.carregando;
  List<Roteiro> _roteiros = [];
  String _erro = "";

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _status = _Status.carregando);
    try {
      final lista = await Repositorio.instance
          .listarRoteiros(busca: _buscaCtrl.text);
      setState(() {
        _roteiros = lista;
        _status = _Status.sucesso;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceFirst("Exception: ", "");
        _status = _Status.erro;
      });
    }
  }

  Future<void> _abrirCriar() async {
    final criou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RoteiroFormScreen()),
    );
    if (criou == true) _carregar();
  }

  void _sair() {
    Repositorio.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Repositorio.instance.usuarioLogado;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Roteiros"),
        actions: [
          IconButton(
            tooltip: "Sair",
            onPressed: _sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      // Botão de criar em destaque
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCriar,
        icon: const Icon(Icons.add),
        label: const Text("Criar roteiro"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (usuario != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Olá, ${usuario.nome}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            // Busca por conteúdo
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _buscaCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _carregar(),
                decoration: InputDecoration(
                  hintText: "Buscar por conteúdo...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _buscaCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _buscaCtrl.clear();
                            _carregar();
                          },
                        ),
                ),
              ),
            ),
            Expanded(child: _corpo()),
          ],
        ),
      ),
    );
  }

  Widget _corpo() {
    switch (_status) {
      case _Status.carregando:
        return const EstadoCarregando(mensagem: "Carregando roteiros...");
      case _Status.erro:
        return EstadoErro(mensagem: _erro, onTentarNovamente: _carregar);
      case _Status.sucesso:
        if (_roteiros.isEmpty) {
          final buscando = _buscaCtrl.text.trim().isNotEmpty;
          // Estado de lista vazia
          return EstadoVazio(
            icone: buscando ? Icons.search_off : Icons.menu_book_outlined,
            titulo: buscando
                ? "Nenhum resultado"
                : "Nenhum roteiro por aqui",
            descricao: buscando
                ? "Não encontramos roteiros com esse conteúdo. Tente outro termo."
                : "Que tal criar o primeiro roteiro de robótica e começar a montar seus passos?",
            acao: buscando
                ? null
                : FilledButton.icon(
                    onPressed: _abrirCriar,
                    icon: const Icon(Icons.add),
                    label: const Text("Criar primeiro roteiro"),
                  ),
          );
        }
        return RefreshIndicator(
          onRefresh: _carregar,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            itemCount: _roteiros.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _RoteiroCard(
              roteiro: _roteiros[i],
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RoteiroDetalheScreen(id: _roteiros[i].id),
                  ),
                );
                _carregar();
              },
            ),
          ),
        );
    }
  }
}

class _RoteiroCard extends StatelessWidget {
  const _RoteiroCard({required this.roteiro, required this.onTap});
  final Roteiro roteiro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.precision_manufacturing_outlined,
                    color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roteiro.resumo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      children: [
                        _Chip(
                          icon: Icons.list_alt,
                          texto:
                              "${roteiro.conteudo.passoAPasso.length} passos",
                        ),
                        _Chip(
                          icon: Icons.image_outlined,
                          texto:
                              "${roteiro.conteudo.imagens.length} imagens",
                        ),
                        if (roteiro.concluido)
                          _Chip(
                            icon: Icons.military_tech,
                            texto: "Medalha",
                            cor: scheme.tertiary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.texto, this.cor});
  final IconData icon;
  final String texto;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final c = cor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 4),
        Text(texto, style: TextStyle(color: c, fontSize: 13)),
      ],
    );
  }
}
