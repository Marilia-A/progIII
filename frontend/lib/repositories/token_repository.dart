import 'package:shared_preferences/shared_preferences.dart';

class TokenRepository {
  static const _chave = 'token';

  Future<String?> ler() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chave);
  }

  Future<void> salvar(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, token);
  }

  Future<void> apagar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}