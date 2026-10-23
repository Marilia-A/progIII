import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/atividade.dart';
import '../services/atividade_service.dart';
import 'atividades_screen.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key, this.atividade});

  final Atividade? atividade;

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final chave = GlobalKey<FormState>();
  final titulo = TextEditingController();
  final descricao = TextEditingController();
  final data = TextEditingController();
  String? categoria;
  DateTime? dataPrevista;
  bool salvando = false;
  String? erro;

  static const categorias = {
    'hardware': 'Hardware',
    'programacao': 'Programação',
    'montagem': 'Montagem',
  };

  @override
  void initState() {
    super.initState();
    final a = widget.atividade;
    if (a != null) {
      titulo.text = a.titulo;
      descricao.text = a.descricao ?? '';
      categoria = a.categoria;
      dataPrevista = a.dataPrevista;
      if (a.dataPrevista != null) data.text = a.dataFormatada;
    }
  }

  Future<void> escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: dataPrevista ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (escolhida == null) return;
    setState(() {
      dataPrevista = escolhida;
      final dia = escolhida.day.toString().padLeft(2, '0');
      final mes = escolhida.month.toString().padLeft(2, '0');
      data.text = '$dia/$mes/${escolhida.year}';
    });
  }

  void limparData() {
    setState(() {
      dataPrevista = null;
      data.clear();
    });
  }

  Future<void> salvar() async {
    if (!chave.currentState!.validate()) {
      return;
    }
    setState(() {
      salvando = true;
      erro = null;
    });
    final servico = context.read<AtividadeService>();
    final texto = descricao.text.trim();
    final desc = texto.isEmpty ? null : texto;
    try {
      if (widget.atividade == null) {
        await servico.criar(titulo.text, desc, categoria!, dataPrevista);
      } else {
        await servico.atualizar(
          widget.atividade!.id,
          titulo.text,
          desc,
          categoria!,
          dataPrevista,
        );
      }
    } on ErroDeAtividades catch (e) {
      setState(() {
        salvando = false;
        erro = '$e';
      });
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titulo.dispose();
    descricao.dispose();
    data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.isFirst) {
      return const AtividadesScreen();
    }
    final editando = widget.atividade != null;
    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar atividade' : 'Nova atividade')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: chave,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: titulo,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if ((valor ?? '').trim().isEmpty) {
                        return 'Informe o título';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descricao,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (valor) {
                      if ((valor ?? '').length > 500) {
                        return 'A descrição pode ter no máximo 500 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final c in categorias.entries)
                        DropdownMenuItem(value: c.key, child: Text(c.value)),
                    ],
                    onChanged: (valor) => setState(() => categoria = valor),
                    validator: (valor) {
                      if (valor == null) {
                        return 'Escolha a categoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: data,
                    readOnly: true,
                    onTap: escolherData,
                    decoration: InputDecoration(
                      labelText: 'Data prevista (opcional)',
                      border: const OutlineInputBorder(),
                      suffixIcon: dataPrevista == null
                          ? const Icon(Icons.calendar_month)
                          : IconButton(
                              tooltip: 'Limpar data',
                              icon: const Icon(Icons.clear),
                              onPressed: limparData,
                            ),
                    ),
                  ),
                  if (erro != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      erro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: salvando ? null : salvar,
                    child: Text(salvando ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}