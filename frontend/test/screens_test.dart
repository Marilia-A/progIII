import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:checklist_robotica/main.dart';
import 'package:checklist_robotica/repositories/usuario_repository.dart';
import 'package:checklist_robotica/routes.dart';
import 'package:checklist_robotica/screens/atividades_screen.dart';
import 'package:checklist_robotica/screens/cadastro_screen.dart';
import 'package:checklist_robotica/screens/inicio_screen.dart';
import 'package:checklist_robotica/screens/login_screen.dart';
import 'package:checklist_robotica/screens/perfil_screen.dart';
import 'package:checklist_robotica/services/sessao_service.dart';

int pedidos = 0;

SessaoService sessaoDeMentira() {
  final cliente = MockClient((pedido) async {
    pedidos++;
    if (pedido.url.path == '/usuarios/login') {
      if (pedido.bodyFields['password'] == 'segredo123') {
        return http.Response(
          jsonEncode({'access_token': 'token-da-ana', 'token_type': 'bearer'}),
          200,
        );
      }
      return http.Response('{"detail": "E-mail ou senha incorretos"}', 401);
    }
    if (pedido.url.path == '/usuarios/eu' &&
        pedido.headers['Authorization'] == 'Bearer token-da-ana') {
      return http.Response(
        jsonEncode({'id': 1, 'nome': 'Ana', 'email': 'ana@robotica.com'}),
        200,
      );
    }
    return http.Response('{"detail": "Not authenticated"}', 401);
  });
  return SessaoService(UsuarioRepository(cliente: cliente));
}

Widget appDeMentira(SessaoService sessao) {
  return ChangeNotifierProvider.value(value: sessao, child: const ChecklistApp());
}

Future<void> preencherEEntrar(WidgetTester tester, String senha) async {
  await tester.enterText(find.byType(TextField).at(0), 'ana@robotica.com');
  await tester.enterText(find.byType(TextField).at(1), senha);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
  await tester.pumpAndSettle();
}

Future<void> abrirOMenu(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login tem e-mail, senha e o botão Entrar', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.text('Criar uma conta'), findsOneWidget);
  });

  testWidgets('cadastro tem nome, e-mail e senha', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });

  testWidgets('senha certa abre a tela inicial pela rota', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    await preencherEEntrar(tester, 'segredo123');
    expect(find.byType(InicioScreen), findsOneWidget);
    expect(find.text('Olá, Ana!'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('senha errada fica no login com o erro', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    await preencherEEntrar(tester, 'senha-errada');
    expect(find.text('E-mail ou senha incorretos'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Criar uma conta abre o cadastro pelo nome da rota', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    await tester.tap(find.text('Criar uma conta'));
    await tester.pumpAndSettle();
    expect(find.byType(CadastroScreen), findsOneWidget);
  });

  testWidgets('guarda: sem sessão, /inicio mostra o login', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    Navigator.of(tester.element(find.byType(LoginScreen))).pushNamed(AppRoutes.inicio);
    await tester.pumpAndSettle();
    expect(find.byType(InicioScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('menu mostra o nome sem receber nada pelo construtor', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    await preencherEEntrar(tester, 'segredo123');
    await abrirOMenu(tester);
    final menu = find.byType(Drawer);
    expect(find.descendant(of: menu, matching: find.text('Ana')), findsOneWidget);
    expect(find.descendant(of: menu, matching: find.text('ana@robotica.com')), findsOneWidget);
    await tester.tap(find.descendant(of: menu, matching: find.text('Perfil')));
    await tester.pumpAndSettle();
    expect(find.byType(PerfilScreen), findsOneWidget);
    await abrirOMenu(tester);
    expect(find.descendant(of: find.byType(Drawer), matching: find.text('Ana')), findsOneWidget);
  });

  testWidgets('sair volta ao login, limpa a pilha e apaga a sessão', (tester) async {
    final sessao = sessaoDeMentira();
    await tester.pumpWidget(appDeMentira(sessao));
    await preencherEEntrar(tester, 'segredo123');
    await tester.tap(find.text('Ver as atividades'));
    await tester.pumpAndSettle();
    expect(find.byType(AtividadesScreen), findsOneWidget);
    await abrirOMenu(tester);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AtividadesScreen), findsNothing);
    expect(Navigator.of(tester.element(find.byType(LoginScreen))).canPop(), isFalse);
    expect(sessao.logado, isFalse);
  });

  testWidgets('watch redesenha a tela quando o service avisa', (tester) async {
    final sessao = sessaoDeMentira();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: sessao,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final nome = context.watch<SessaoService>().usuario?.nome;
              return Text(nome ?? 'ninguém');
            },
          ),
        ),
      ),
    );
    expect(find.text('ninguém'), findsOneWidget);
    await sessao.entrar('ana@robotica.com', 'segredo123');
    await tester.pump();
    expect(find.text('Ana'), findsOneWidget);
  });

  test('service recusa campos vazios sem chamar a API', () async {
    final sessao = sessaoDeMentira();
    pedidos = 0;
    await expectLater(sessao.entrar('', ''), throwsA(isA<ErroDeLogin>()));
    expect(pedidos, 0);
    expect(sessao.logado, isFalse);
  });

  test('entrar e sair mudam a sessão e avisam quem está de olho', () async {
    final sessao = sessaoDeMentira();
    var avisos = 0;
    sessao.addListener(() => avisos++);
    await sessao.entrar('ana@robotica.com', 'segredo123');
    expect(sessao.token, 'token-da-ana');
    expect(sessao.usuario?.nome, 'Ana');
    expect(avisos, 1);
    sessao.sair();
    expect(sessao.logado, isFalse);
    expect(sessao.usuario, isNull);
    expect(avisos, 2);
  });
}