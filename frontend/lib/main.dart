import 'package:srcFlutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const RoboticaApp());

class RoboticaApp extends StatelessWidget {
  const RoboticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Robótica Educacional",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
