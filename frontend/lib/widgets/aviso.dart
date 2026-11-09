import 'package:flutter/material.dart';

// O aviso de toda ação: verde quando deu certo, vermelho quando não deu.
void avisar(BuildContext context, String texto, {bool erro = false}) {
  final mensageiro = ScaffoldMessenger.of(context);
  mensageiro.hideCurrentSnackBar();
  mensageiro.showSnackBar(
    SnackBar(
      content: Text(texto),
      backgroundColor: erro ? Colors.red : Colors.green,
    ),
  );
}