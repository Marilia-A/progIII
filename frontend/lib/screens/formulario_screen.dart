import 'package:flutter/material.dart';
import '../models/atividade.dart';
import '../services/api_service.dart';

class FormularioScreen extends StatefulWidget {
  final Atividade? atividade; // null = criar, preenchido = editar

  const FormularioScreen({super.key, this.atividade});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late CategoriaAtividade _categoria;
  late bool _concluida;
  DateTime? _dataPrevista;

  bool _carregando = false;
  String? _erro;

  bool get _editando => widget.atividade != null;

  @override
  void initState() {
    super.initState();
    final a = widget.atividade;
    _tituloController = TextEditingController(text: a?.titulo ?? '');
    _descricaoController = TextEditingController(text: a?.descricao ?? '');
    _categoria = a?.categoria ?? CategoriaAtividade.hardware;
    _concluida = a?.concluida ?? false;
    _dataPrevista = a?.dataPrevista;
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataPrevista ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (data != null) setState(() => _dataPrevista = data);
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final atividade = Atividade(
        id: widget.atividade?.id,
        titulo: _tituloController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        categoria: _categoria,
        concluida: _concluida,
        dataPrevista: _dataPrevista,
      );

      if (_editando) {
        await _apiService.atualizar(widget.atividade!.id!, atividade.toJson());
      } else {
        await _apiService.criar(atividade);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // true = houve alteração
    } catch (e) {
      setState(() => _erro = 'Não foi possível salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar atividade' : 'Nova atividade')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) return 'Informe o título';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoriaAtividade>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: CategoriaAtividade.values.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c.valor));
                }).toList(),
                onChanged: (valor) => setState(() => _categoria = valor!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_dataPrevista == null
                    ? 'Data prevista (opcional)'
                    : 'Data: ${_dataPrevista!.day}/${_dataPrevista!.month}/${_dataPrevista!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selecionarData,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Concluída'),
                value: _concluida,
                onChanged: (valor) => setState(() => _concluida = valor),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _carregando ? null : _salvar,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}