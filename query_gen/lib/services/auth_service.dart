import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage  = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _emailKey = 'user_email';
  static const _nomeKey  = 'user_nome';

  Future<void> saveToken(String token, String email, {String? nome}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _emailKey, value: email);
    if (nome != null) {
      await _storage.write(key: _nomeKey, value: nome);
    }
  }

  Future<String?> getToken() async => _storage.read(key: _tokenKey);
  Future<String?> getEmail() async => _storage.read(key: _emailKey);
  Future<String?> getNome()  async => _storage.read(key: _nomeKey);

  Future<void> saveNome(String nome) async =>
      _storage.write(key: _nomeKey, value: nome);

  Future<void> logout() async => _storage.deleteAll();

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
