import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:checklist_robotica/repositories/atividade_repository.dart';
import 'package:checklist_robotica/repositories/usuario_repository.dart';
import 'package:checklist_robotica/screens/atividades_screen.dart';
import 'package:checklist_robotica/services/atividade_service.dart';
import 'package:checklist_robotica/services/sessao_service.dart';

// A lista pede as atividades à API. Aqui, quem responde é uma API de mentira:
// para qualquer pedido, ela devolve o texto que o teste escolheu.
Future<void> abrirALista(WidgetTester tester, String respostaDaApi) async {
  final api = MockClient((pedido) async => http.Response(respostaDaApi, 200));
  final sessao = SessaoService(UsuarioRepository());
  sessao.token = 'um-token';
  final atividades = AtividadeService(AtividadeRepository(cliente: api), sessao);
  await tester.pumpWidget(
    Provider.value(
      value: atividades,
      child: const MaterialApp(home: AtividadesScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a lista mostra a atividade que a API devolveu', (tester) async {
    await abrirALista(
      tester,
      '[{"id": 1, "titulo": "Montar o circuito do LED", "descricao": null, '
      '"categoria": "hardware", "concluida": false, "data_prevista": null, "dono_id": 1}]',
    );
    expect(find.text('Montar o circuito do LED'), findsOneWidget);
    expect(find.text('Nenhuma atividade ainda.'), findsNothing);
  });

  testWidgets('sem atividade nenhuma, a lista avisa que está vazia', (tester) async {
    await abrirALista(tester, '[]');
    expect(find.text('Nenhuma atividade ainda.'), findsOneWidget);
  });
}