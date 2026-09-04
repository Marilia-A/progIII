import 'package:flutter/material.dart';
import '../models/atividade.dart';
import '../services/api_service.dart';
import 'formulario_screen.dart';
import 'detalhe_screen.dart';

class ListagemScreen extends StatefulWidget {
  const ListagemScreen({super.key});

  @override
  State<ListagemScreen> createState() => _ListagemScreenState();
}

enum _Estado { carregando, erro, sucesso }

class _ListagemScreenState extends State<ListagemScreen> {
  final _apiService = ApiService();
  final _buscaController = TextEditingController();

  _Estado _estado = _Estado.carregando;
  List<Atividade> _atividades = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _estado = _Estado.carregando);
    try {
      final lista = await _apiService.listar(
        busca: _buscaController.text.isEmpty ? null : _buscaController.text,
      );
      setState(() {
        _atividades = lista;
        _estado = _Estado.sucesso;
      });
    } catch (e) {
      setState(() => _estado = _Estado.erro);
    }
  }

  void _abrirFormulario({Atividade? atividade}) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormularioScreen(atividade: atividade)),
    );
    if (alterou == true) _carregar();
  }

  void _abrirDetalhe(Atividade atividade) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetalheScreen(atividade: atividade)),
    );
    if (alterou == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Atividades')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _buscaController.clear();
                    _carregar();
                  },
                ),
              ),
              onSubmitted: (_) => _carregar(),
            ),
          ),
          Expanded(child: _corpo()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }

  Widget _corpo() {
    switch (_estado) {
      case _Estado.carregando:
        return const Center(child: CircularProgressIndicator());

      case _Estado.erro:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Não foi possível carregar as atividades.'),
              const SizedBox(height: 12),
              FilledButton(onPressed: _carregar, child: const Text('Tentar novamente')),
            ],
          ),
        );

      case _Estado.sucesso:
        if (_atividades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.checklist, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Nenhuma atividade ainda.'),
                const SizedBox(height: 4),
                const Text('Toque em "Novo" para criar a primeira.'),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _carregar,
          child: ListView.builder(
            itemCount: _atividades.length,
            itemBuilder: (context, index) {
              final a = _atividades[index];
              return ListTile(
                leading: Icon(
                  a.concluida ? Icons.check_circle : Icons.circle_outlined,
                  color: a.concluida ? Colors.green : Colors.grey,
                ),
                title: Text(a.titulo),
                subtitle: Text(a.categoria.valor),
                onTap: () => _abrirDetalhe(a),
              );
            },
          ),
        );
    }
  }
}