import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checklist_robotica/main.dart';
import 'package:checklist_robotica/models/atividade.dart';
import 'package:checklist_robotica/repositories/atividade_repository.dart';
import 'package:checklist_robotica/repositories/usuario_repository.dart';
import 'package:checklist_robotica/routes.dart';
import 'package:checklist_robotica/screens/atividade_screen.dart';
import 'package:checklist_robotica/screens/atividades_screen.dart';
import 'package:checklist_robotica/screens/cadastro_screen.dart';
import 'package:checklist_robotica/screens/inicio_screen.dart';
import 'package:checklist_robotica/screens/login_screen.dart';
import 'package:checklist_robotica/screens/perfil_screen.dart';
import 'package:checklist_robotica/services/atividade_service.dart';
import 'package:checklist_robotica/services/sessao_service.dart';

int pedidos = 0;

SessaoService sessaoDeMentira({Map<String, Object> guardado = const {}}) {
  SharedPreferences.setMockInitialValues(guardado);
  final contas = {
    'ana@robotica.com': {'nome': 'Ana', 'senha': 'segredo123'},
  };
  final cliente = MockClient((pedido) async {
    pedidos++;
    if (pedido.url.path == '/usuarios/' && pedido.method == 'POST') {
      final dados = jsonDecode(pedido.body);
      if (contas.containsKey(dados['email'])) {
        return http.Response(
          '{"detail": "Ja existe uma conta com o e-mail ${dados['email']}"}',
          409,
        );
      }
      if (dados['senha'].length < 6) {
        return http.Response(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'senha'],
                'msg': 'String should have at least 6 characters',
              },
            ],
          }),
          422,
        );
      }
      contas[dados['email']] = {'nome': dados['nome'], 'senha': dados['senha']};
      return http.Response(
        jsonEncode({'id': 2, 'nome': dados['nome'], 'email': dados['email']}),
        201,
      );
    }
    if (pedido.url.path == '/usuarios/login') {
      final email = pedido.bodyFields['username'];
      if (contas[email]?['senha'] == pedido.bodyFields['password']) {
        return http.Response(
          jsonEncode({'access_token': 'token-de-$email', 'token_type': 'bearer'}),
          200,
        );
      }
      return http.Response('{"detail": "E-mail ou senha incorretos"}', 401);
    }
    if (pedido.url.path == '/usuarios/eu') {
      final email = (pedido.headers['Authorization'] ?? '').replaceFirst(
        'Bearer token-de-',
        '',
      );
      if (contas.containsKey(email)) {
        return http.Response(
          jsonEncode({'id': 1, 'nome': contas[email]!['nome'], 'email': email}),
          200,
        );
      }
    }
    return http.Response('{"detail": "Token invalido ou vencido"}', 401);
  });
  return SessaoService(UsuarioRepository(cliente: cliente));
}

const duasAtividades = [
  {
    'id': 1,
    'titulo': 'Montar o circuito do LED',
    'descricao': 'LED e resistor na porta 13',
    'categoria': 'hardware',
    'concluida': false,
    'data_prevista': '2026-10-25',
    'dono_id': 1,
  },
  {
    'id': 2,
    'titulo': 'Programar o pisca-pisca',
    'descricao': null,
    'categoria': 'programacao',
    'concluida': true,
    'data_prevista': null,
    'dono_id': 1,
  },
];

http.Client apiDeAtividades(int status, Object corpo) {
  return MockClient((pedido) async {
    pedidos++;
    if (pedido.headers['Authorization'] == null) {
      return http.Response('{"detail": "Not authenticated"}', 401);
    }
    final id = pedido.url.pathSegments.last;
    if (id.isNotEmpty) {
      for (final atividade in duasAtividades) {
        if ('${atividade['id']}' == id) {
          return http.Response(jsonEncode(atividade), 200);
        }
      }
      return http.Response('{"detail": "Atividade $id nao encontrada"}', 404);
    }
    return http.Response(jsonEncode(corpo), status);
  });
}

Widget appDeMentira(SessaoService sessao, {http.Client? atividades}) {
  final repositorio = AtividadeRepository(
    cliente: atividades ?? apiDeAtividades(200, []),
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: sessao),
      Provider.value(value: AtividadeService(repositorio, sessao)),
    ],
    child: const ChecklistApp(),
  );
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

Future<void> preencherECadastrar(WidgetTester tester, String email, String senha) async {
  await tester.tap(find.text('Criar uma conta'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), 'Bia');
  await tester.enterText(find.byType(TextField).at(1), email);
  await tester.enterText(find.byType(TextField).at(2), senha);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
  await tester.pumpAndSettle();
}

Future<void> abrirAsAtividades(WidgetTester tester, http.Client atividades) async {
  final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@robotica.com'});
  await sessao.restaurar();
  await tester.pumpWidget(appDeMentira(sessao, atividades: atividades));
  await tester.tap(find.text('Ver as atividades'));
  await tester.pumpAndSettle();
}

Future<String?> tokenGuardado() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Matcher recusadoCom(String frase) {
  return throwsA(isA<ErroDeCadastro>().having((e) => e.mensagem, 'mensagem', frase));
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

  testWidgets('cadastrar pela tela cria a conta e abre a tela inicial', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    await preencherECadastrar(tester, 'bia@robotica.com', 'segredo456');
    expect(find.byType(InicioScreen), findsOneWidget);
    expect(find.text('Olá, Bia!'), findsOneWidget);
    expect(find.byType(CadastroScreen), findsNothing);
  });

  testWidgets('e-mail repetido: a tela mostra o erro e fica no cadastro', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    await preencherECadastrar(tester, 'ana@robotica.com', 'segredo456');
    expect(find.text('Já existe uma conta com este e-mail'), findsOneWidget);
    expect(find.byType(CadastroScreen), findsOneWidget);
    expect(find.byType(InicioScreen), findsNothing);
  });

  testWidgets('Já tenho conta leva ao login', (tester) async {
    await tester.pumpWidget(appDeMentira(sessaoDeMentira()));
    await tester.tap(find.text('Criar uma conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Já tenho conta'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(CadastroScreen), findsNothing);
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
    expect(await tokenGuardado(), 'token-de-ana@robotica.com');
    await abrirOMenu(tester);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AtividadesScreen), findsNothing);
    expect(Navigator.of(tester.element(find.byType(LoginScreen))).canPop(), isFalse);
    expect(sessao.logado, isFalse);
    expect(await tokenGuardado(), isNull);
  });

  testWidgets('com a sessão restaurada, o app abre direto na tela inicial', (tester) async {
    final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@robotica.com'});
    await sessao.restaurar();
    await tester.pumpWidget(appDeMentira(sessao));
    expect(find.byType(InicioScreen), findsOneWidget);
    expect(find.text('Olá, Ana!'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
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

  testWidgets('a tela de atividades mostra a lista: um ListTile por atividade', (tester) async {
    await abrirAsAtividades(tester, apiDeAtividades(200, duasAtividades));
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Montar o circuito do LED'), findsOneWidget);
    expect(find.text('Hardware · 25/10/2026'), findsOneWidget);
  });

  testWidgets('sem atividade nenhuma, a tela diz que a lista está vazia', (tester) async {
    await abrirAsAtividades(tester, apiDeAtividades(200, []));
    expect(find.text('Nenhuma atividade ainda.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('com a API parada, o erro; o Tentar de novo pede outra vez', (tester) async {
    var noAr = false;
    final atividades = MockClient((pedido) async {
      if (!noAr) {
        throw http.ClientException('Failed to fetch');
      }
      return http.Response(jsonEncode(duasAtividades), 200);
    });
    await abrirAsAtividades(tester, atividades);
    expect(find.text('Não consegui carregar as atividades'), findsOneWidget);
    expect(find.text('Não consegui falar com a API. O uvicorn está rodando?'), findsOneWidget);
    noAr = true;
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tentar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('Montar o circuito do LED'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsNothing);
  });

  testWidgets('enquanto a resposta não chega, a tela mostra o carregando', (tester) async {
    final resposta = Completer<http.Response>();
    final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@robotica.com'});
    await sessao.restaurar();
    await tester.pumpWidget(
      appDeMentira(sessao, atividades: MockClient((pedido) => resposta.future)),
    );
    await tester.tap(find.text('Ver as atividades'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    resposta.complete(http.Response(jsonEncode(duasAtividades), 200));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Montar o circuito do LED'), findsOneWidget);
  });

  testWidgets('tocar numa atividade abre o detalhe, que busca na API pelo id', (tester) async {
    await abrirAsAtividades(tester, apiDeAtividades(200, duasAtividades));
    pedidos = 0;
    await tester.tap(find.text('Programar o pisca-pisca'));
    await tester.pumpAndSettle();
    expect(find.byType(AtividadeScreen), findsOneWidget);
    expect(find.text('Programação'), findsOneWidget);
    expect(find.text('Sem descrição'), findsOneWidget);
    expect(find.text('Concluída'), findsOneWidget);
    expect(pedidos, 1);
  });

  testWidgets('o detalhe de uma atividade que não existe mostra o erro da API', (tester) async {
    await abrirAsAtividades(tester, apiDeAtividades(200, duasAtividades));
    Navigator.of(tester.element(find.byType(AtividadesScreen)))
        .pushNamed(AppRoutes.atividade, arguments: 99);
    await tester.pumpAndSettle();
    expect(find.text('Não consegui carregar a atividade'), findsOneWidget);
    expect(find.text('Atividade 99 nao encontrada'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('sem o id na rota (o F5 no detalhe), a tela mostra a lista', (tester) async {
    await abrirAsAtividades(tester, apiDeAtividades(200, duasAtividades));
    Navigator.of(tester.element(find.byType(AtividadesScreen)))
        .pushNamed(AppRoutes.atividade);
    await tester.pumpAndSettle();
    expect(find.byType(AtividadeScreen), findsOneWidget);
    expect(find.text('Montar o circuito do LED'), findsOneWidget);
  });

  test('service recusa campos vazios sem chamar a API', () async {
    final sessao = sessaoDeMentira();
    pedidos = 0;
    await expectLater(sessao.entrar('', ''), throwsA(isA<ErroDeLogin>()));
    await expectLater(sessao.cadastrar('', '', ''), recusadoCom('Preencha o nome, o e-mail e a senha'));
    expect(pedidos, 0);
    expect(sessao.logado, isFalse);
  });

  test('entrar e sair mudam a sessão e avisam quem está de olho', () async {
    final sessao = sessaoDeMentira();
    var avisos = 0;
    sessao.addListener(() => avisos++);
    await sessao.entrar('ana@robotica.com', 'segredo123');
    expect(sessao.token, 'token-de-ana@robotica.com');
    expect(sessao.usuario?.nome, 'Ana');
    expect(avisos, 1);
    await sessao.sair();
    expect(sessao.logado, isFalse);
    expect(sessao.usuario, isNull);
    expect(avisos, 2);
  });

  test('cadastrar cria a conta e já entra com ela', () async {
    final sessao = sessaoDeMentira();
    await sessao.cadastrar('Bia', 'bia@robotica.com', 'segredo456');
    expect(sessao.logado, isTrue);
    expect(sessao.usuario?.nome, 'Bia');
    expect(sessao.token, 'token-de-bia@robotica.com');
  });

  test('service traduz a recusa da API: 409 e 422', () async {
    final sessao = sessaoDeMentira();
    await expectLater(
      sessao.cadastrar('Ana', 'ana@robotica.com', 'segredo123'),
      recusadoCom('Já existe uma conta com este e-mail'),
    );
    await expectLater(
      sessao.cadastrar('Bia', 'bia@robotica.com', '123'),
      recusadoCom('senha: String should have at least 6 characters'),
    );
    expect(sessao.logado, isFalse);
    expect(await tokenGuardado(), isNull);
  });

  test('entrar guarda o token no aparelho', () async {
    final sessao = sessaoDeMentira();
    await sessao.entrar('ana@robotica.com', 'segredo123');
    expect(await tokenGuardado(), 'token-de-ana@robotica.com');
  });

  test('restaurar devolve a sessão a quem tem um token guardado', () async {
    final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@robotica.com'});
    pedidos = 0;
    await sessao.restaurar();
    expect(sessao.logado, isTrue);
    expect(sessao.usuario?.nome, 'Ana');
    expect(pedidos, 1);
  });

  test('restaurar sem token guardado não pede nada à API', () async {
    final sessao = sessaoDeMentira();
    pedidos = 0;
    await sessao.restaurar();
    expect(sessao.logado, isFalse);
    expect(pedidos, 0);
  });

  test('restaurar apaga o token que a API não aceita mais', () async {
    final sessao = sessaoDeMentira(guardado: {'token': 'token-vencido'});
    await sessao.restaurar();
    expect(sessao.logado, isFalse);
    expect(await tokenGuardado(), isNull);
  });

  test('sair apaga o token guardado no aparelho', () async {
    final sessao = sessaoDeMentira(guardado: {'token': 'token-de-ana@robotica.com'});
    await sessao.restaurar();
    expect(sessao.logado, isTrue);
    await sessao.sair();
    expect(await tokenGuardado(), isNull);
  });

  test('o repositório manda o token no cabeçalho e devolve objetos Atividade', () async {
    String? cabecalho;
    final cliente = MockClient((pedido) async {
      cabecalho = pedido.headers['Authorization'];
      return http.Response(jsonEncode(duasAtividades), 200);
    });
    final atividades = await AtividadeRepository(cliente: cliente).listar('tk-123');
    expect(cabecalho, 'Bearer tk-123');
    expect(atividades, hasLength(2));
    expect(atividades.first, isA<Atividade>());
    expect(atividades.first.titulo, 'Montar o circuito do LED');
    expect(atividades.last.concluida, isTrue);
    expect(atividades.last.dataPrevista, isNull);
  });

  test('o repositório busca uma atividade pelo id: GET /atividades/2', () async {
    String? caminho;
    String? cabecalho;
    final cliente = MockClient((pedido) async {
      caminho = pedido.url.path;
      cabecalho = pedido.headers['Authorization'];
      return http.Response(jsonEncode(duasAtividades.last), 200);
    });
    final atividade = await AtividadeRepository(cliente: cliente).buscar('tk-123', 2);
    expect(caminho, '/atividades/2');
    expect(cabecalho, 'Bearer tk-123');
    expect(atividade.titulo, 'Programar o pisca-pisca');
  });

  test('o service das atividades traduz a recusa: a frase da API vai para a tela', () async {
    final sessao = sessaoDeMentira();
    await sessao.entrar('ana@robotica.com', 'segredo123');
    final recusa = apiDeAtividades(401, {'detail': 'Token invalido ou vencido'});
    final servico = AtividadeService(AtividadeRepository(cliente: recusa), sessao);
    await expectLater(
      servico.listar(),
      throwsA(isA<ErroDeAtividades>().having((e) => '$e', 'texto', 'Token invalido ou vencido')),
    );
  });
}