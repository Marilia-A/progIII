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
  String busca = '';
  final campoDaBusca = TextEditingController();

  @override
  void initState() {
    super.initState();
    atividades = context.read<AtividadeService>().listar();
  }

  @override
  void dispose() {
    campoDaBusca.dispose();
    super.dispose();
  }

  void pedirDeNovo() {
    setState(() {
      atividades = context.read<AtividadeService>().listar(busca: busca);
    });
  }

  // Quem filtra é a API (o ?titulo=), e não a tela.
  void buscar(String texto) {
    busca = texto.trim();
    pedirDeNovo();
  }

  void limparABusca() {
    campoDaBusca.clear();
    buscar('');
  }

  Widget listaDasAtividades() {
    return FutureBuilder<List<Atividade>>(
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
          final frase = busca.isEmpty
              ? 'Nenhuma atividade ainda.'
              : 'Nenhuma atividade com "$busca" no título.';
          return Center(child: Text(frase));
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: campoDaBusca,
              decoration: InputDecoration(
                labelText: 'Buscar pelo título',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpar a busca',
                  onPressed: limparABusca,
                ),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: buscar,
            ),
          ),
          Expanded(child: listaDasAtividades()),
        ],
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