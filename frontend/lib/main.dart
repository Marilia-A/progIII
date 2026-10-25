import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/atividade.dart';
import 'repositories/atividade_repository.dart';
import 'repositories/token_repository.dart';
import 'repositories/usuario_repository.dart';
import 'routes.dart';
import 'screens/atividade_screen.dart';
import 'screens/atividades_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/formulario_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'services/atividade_service.dart';
import 'services/sessao_service.dart';
import 'widgets/rota_protegida.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessao = SessaoService(UsuarioRepository(), tokens: TokenRepository());
  await sessao.restaurar();
  final atividades = AtividadeService(AtividadeRepository(), sessao);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessao),
        Provider.value(value: atividades),
      ],
      child: const ChecklistApp(),
    ),
  );
}

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist de Robótica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.cadastro: (context) => const CadastroScreen(),
        AppRoutes.inicio: (context) => const RotaProtegida(tela: InicioScreen()),
        AppRoutes.atividades: (context) => const RotaProtegida(tela: AtividadesScreen()),
        AppRoutes.atividade: (context) => RotaProtegida(
              tela: AtividadeScreen(
                id: ModalRoute.of(context)!.settings.arguments as int?,
              ),
            ),
        AppRoutes.formulario: (context) => RotaProtegida(
              tela: FormularioScreen(
                atividade: ModalRoute.of(context)!.settings.arguments as Atividade?,
              ),
            ),
        AppRoutes.perfil: (context) => const RotaProtegida(tela: PerfilScreen()),
      },
    );
  }
}